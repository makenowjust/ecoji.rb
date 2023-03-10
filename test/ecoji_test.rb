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
    check 'k', 'š½āāā', 'š½ā'
    check "\x00\x01", 'ššāā', 'šāā'
    check "\x00\x01\x02", 'šššā', 'šāšā'
    check "\x00\x01\x02\x00", 'šššā', 'šāšš„·'
    check "Base64 is so 1999, isn't there something better?",
          'šš©š¦ššššÆššš½ššš±š„šš±šš­š®šµš¢š„š­šøšš²š¦š¶š¢š„š®šŗššøš®š¼š¦šš„°ā',
          'š§š©š§šš§ššÆššš½āšš±š„šš±šš­š®āš¢šŖ š­š©“šš²š¦š¶š¢šŖ š®š©¹ššøš®š¼š¦šš„°ā'
    check 'č²ćÆåćøć©ę£ćć¬ćć',
          'š„š£šš¤®šš«šš®šš¤¼š­šŗš„š«šš¤Æš½šš³š°ššš­šŗ',
          'š„š£šš¤®šš«šš®šš¤¼š­šŗš„š«šš¤Æš§®šš³š°ššš­šŗ'
  end

  def check_decode(data, encoded)
    assert_equal data, Ecoji.decode(encoded)
  end

  def test_decode_newline
    check_decode '1234567890abc', "š\nš\nš\nšø\nš„\nš¤ \nš \nš\nš\nšø\nš\nā"
    check_decode '1234567890abc', "š\nš\nš¦æ\nš¦£\nš„\nš¤ \nš \nš\nš\nšø\nš\nā"
    check_decode '1234567890abc', "š\r\nš\r\nš\r\nšø\r\nš„\r\nš¤ \r\nš \r\nš\r\nš\r\nšø\r\nš\r\nā"
    check_decode '1234567890abc', "š\r\nš\r\nš¦æ\r\nš¦£\r\nš„\r\nš¤ \r\nš \r\nš\r\nš\r\nšø\r\nš\r\nā"
  end

  def test_decode_concatenated
    check_decode 'abcdefxyz', 'ššøš§š­š©āš²š„šŖā'
    check_decode "abc6789XY\n", 'ššøšāš„š¤ š šš²š”šā'

    check_decode 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrs',
                 'šāāāšš³āāšššāš«šš„šš¾šš”š¢šš£šš¢š„āāāšŖššØš«ššāāššÆššš©š¤°šāššøš¦š­šŖšš¬ššŗšššæššš¤š'

    check_decode 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrs',
                 'šāš§š„±āš§ššāš«šš„šš§¦šš«£š§½šš£šš«¤š„āšŖššØš«ššāššÆš§šš©š¤°šāššøš§š­šŖšŖš¬š¼šŗššš§Øššš¦©šŖ'
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
    check_decode_error('š š”š¤š©', /Non Ecoji character seen/)

    check_decode_error('š¶š¶š¶š¶š¶', /Unexpected end of data, input data size not multiple of 4/)

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
