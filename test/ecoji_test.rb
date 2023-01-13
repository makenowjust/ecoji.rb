# frozen_string_literal: true

require 'test_helper'

class EcojiTest < Minitest::Test
  def check(data, expected_v1, expected_v2)
    assert_equal expected_v1, Ecoji.encode(data, version: 1)
    assert_equal data, Ecoji.decode(expected_v1)

    assert_equal expected_v2, Ecoji.encode(data, version: 2)
    assert_equal data, Ecoji.decode(expected_v2)
  end

  def test_encode_decode
    check '', '', ''
    check 'k', '👽☕☕☕', '👽☕'
    check "\x00\x01", '🀄🆚☕☕', '🀄♓☕'
    check "\x00\x01\x02", '🀄🆚🍈☕', '🀄♓🍈☕'
    check "\x00\x01\x02\x00", '🀄🆚🍈⚜', '🀄♓🍈🥷'
    check "Base64 is so 1999, isn't there something better?",
          '🏗📩🎦🐇🎛📘🔯🚜💞😽🆖🐊🎱🥁🚄🌱💞😭💮🇵💢🕥🐭🔸🍉🚲🦑🐶💢🕥🔮🔺🍉📸🐮🌼👦🚟🥰☕',
          '🧏📩🧈🐇🧅📘🔯🚜💞😽♏🐊🎱🥁🚄🌱💞😭💮✊💢🪠🐭🩴🍉🚲🦑🐶💢🪠🔮🩹🍉📸🐮🌼👦🚟🥰☕'
    check '色は匂へど散りぬるを',
          '🥒🍣🎀🤮😊🔫🚜😮📘🤼🎭👺🥊🐫🏅🤯📽🔋🌳🎰📜🎆🎭🕺',
          '🥒🍣🎀🤮😊🔫🚜😮📘🤼🎭👺🥊🐫🏅🤯🧮🔋🌳🎰📜🎆🎭🕺'
  end

  def check_decode(data, encoded)
    assert_equal data, Ecoji.decode(encoded)
  end

  def test_decode_newline
    check_decode '1234567890abc', "🎌\n🚟\n🎗\n🈸\n🎥\n🤠\n📠\n🐁\n👖\n📸\n🎈\n☕"
    check_decode '1234567890abc', "🎌\n🚟\n🦿\n🦣\n🎥\n🤠\n📠\n🐁\n👖\n📸\n🎈\n☕"
    check_decode '1234567890abc', "🎌\r\n🚟\r\n🎗\r\n🈸\r\n🎥\r\n🤠\r\n📠\r\n🐁\r\n👖\r\n📸\r\n🎈\r\n☕"
    check_decode '1234567890abc', "🎌\r\n🚟\r\n🦿\r\n🦣\r\n🎥\r\n🤠\r\n📠\r\n🐁\r\n👖\r\n📸\r\n🎈\r\n☕"
  end

  def test_decode_concatenated
    check_decode 'abcdefxyz', '👖📸🧈🌭👩☕💲🥇🪚☕'
    check_decode "abc6789XY\n", '👖📸🎈☕🎥🤠📠🏍🐲👡🕟☕'

    check_decode 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrs',
                 '🏒☕☕☕🏗🈳☕☕🏟🌚👑☕🏫🍌🔥📑🏾🎌🛡🔢🐒🏣🍜🛢🐥☕☕☕🐪👆📨🐫🎈🚌☕☕🎐🚯🏛🐇🎩🤰🔓☕👖📸🎦🌭👪🕕📬🏍👺😁🚗🐿💎🚃🌤🕒'

    check_decode 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrs',
                 '🏒☕🧏🥱☕🧝🌚👑☕🏫🍌🔥📑🧦🎌🫣🧽🐒🏣🍜🫤🐥☕🐪👆📨🐫🎈🚌☕🎐🚯🧙🐇🎩🤰🔓☕👖📸🧈🌭👪🪐📬🛼👺😁🚗🧨💎🚃🦩🪄'
  end

  def check_decode_error(encoded, expected_message)
    encoded = encoded.pack('U*') if encoded.is_a?(Array)
    begin
      Ecoji.decode(encoded)
    rescue Ecoji::Error => e
      assert e.message =~ expected_message,
             "Unmatched exception message: #{e.message.inspect}, expected: #{expected_message}"
    rescue StandardError => e
      raise "Unexpected exception: #{e.class}: #{e.message}"
    else
      raise 'Exception was not raised'
    end
  end

  def test_decode_garbage
    check_decode_error('not emojisV2', /Non Ecoji character seen/)
    check_decode_error('🟠🟡🤍🟩', /Non Ecoji character seen/)

    check_decode_error('🌶🌶🌶🌶🌶', /Unexpected end of data, input data size not multiple of 4/)

    check_decode_error([Ecoji::PADDING_LAST_V1[0]] + (0..2).map do |i|
                                                       Ecoji::Emojis::V1[i]
                                                     end, /Last padding seen in unexpected position/)
    check_decode_error([Ecoji::PADDING_LAST_V2[0]] + (0..2).map do |i|
                                                       Ecoji::Emojis::V2[i]
                                                     end, /Last padding seen in unexpected position/)
    check_decode_error([Ecoji::Emojis::V1[0], Ecoji::PADDING_LAST_V1[0]] + (1..2).map do |i|
                                                                             Ecoji::Emojis::V1[i]
                                                                           end, /Last padding seen in unexpected position/)
    check_decode_error([Ecoji::Emojis::V2[0], Ecoji::PADDING_LAST_V2[0]] + (1..2).map do |i|
                                                                             Ecoji::Emojis::V2[i]
                                                                           end, /Last padding seen in unexpected position/)

    check_decode_error([0x1f004, 0x1f170, Ecoji::PADDING, 0x1f93e], /Unexpectedly saw non-padding after padding/)

    check_decode_error([Ecoji::PADDING] + (1..3).map do |i|
                                            Ecoji::Emojis::V2[i]
                                          end, /Padding unexpectedly seen in first position/)
    check_decode_error((1..4).map do |i|
                         Ecoji::Emojis::V2[i]
                       end + ([Ecoji::PADDING] * 4), /Padding unexpectedly seen in first position/)

    check_decode_error((1..3).map do |i|
                         Ecoji::Emojis::V2[i]
                       end, /Unexpected end of data, input data size not multiple of 4/)
    check_decode_error((1..5).map do |i|
                         Ecoji::Emojis::V2[i]
                       end, /Unexpected end of data, input data size not multiple of 4/)
  end

  def test_decode_mixed
    check_decode_error([0x1f004, 0x1f170, 0x1f93f, 0x1f93e], /Emojis from different ecoji versions seen/)
    check_decode_error([0x1f004, 0x1f93f, 0x1f170, 0x1f93e], /Emojis from different ecoji versions seen/)
    check_decode_error(
      [0x1f004, 0x1f170, 0x1f170, 0x1f93e, 0x1f004, 0x1f170, 0x1f170, 0x1f93e, 0x1f004, 0x1f170, 0x1f93f,
       0x1f93e], /Emojis from different ecoji versions seen/
    )

    check_decode_error([0x1f004, 0x1f170, 0x1f004, Ecoji::PADDING_LAST_V2[0]],
                       /Emojis from different ecoji versions seen/)
    check_decode_error([0x1f004, 0x1f170, 0x1f004, Ecoji::PADDING_LAST_V2[1]],
                       /Emojis from different ecoji versions seen/)

    check_decode_error([0x1f004, 0x1f004, 0x1f93f, Ecoji::PADDING_LAST_V1[0]],
                       /Emojis from different ecoji versions seen/)
    check_decode_error([0x1f004, 0x1f004, 0x1f93f, Ecoji::PADDING_LAST_V1[1]],
                       /Emojis from different ecoji versions seen/)
  end
end
