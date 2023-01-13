# frozen_string_literal: true

module Ecoji
end

require 'ecoji/emojis'
require 'ecoji/version'

module Ecoji
  class Error < StandardError; end

  PADDING = 0x2615
  PADDING_LAST_V1 = [0x269C, 0x1F3CD, 0x1F4D1, 0x1F64B].freeze
  PADDING_LAST_V2 = [0x1F977, 0x1F6FC, 0x1F4D1, 0x1F64B].freeze

  REV_EMOJIS = begin
    map = {}

    Emojis::V1.each_with_index do |n, ordinal|
      map[n] = { ordinal:, version: 1, padding: :none }
    end

    Emojis::V2.each_with_index do |n, ordinal|
      if map[n]
        map[n][:version] = 3
      else
        map[n] = { ordinal:, version: 2, padding: :none }
      end
    end

    map[PADDING] = { ordinal: 0, version: 3, padding: :fill }
    map[PADDING_LAST_V1[0]] = { ordinal: 0, version: 1, padding: :last }
    map[PADDING_LAST_V1[1]] = { ordinal: 1 << 8, version: 1, padding: :last }
    map[PADDING_LAST_V1[2]] = { ordinal: 2 << 8, version: 3, padding: :last }
    map[PADDING_LAST_V1[3]] = { ordinal: 3 << 8, version: 3, padding: :last }
    map[PADDING_LAST_V2[0]] = { ordinal: 0, version: 2, padding: :last }
    map[PADDING_LAST_V2[1]] = { ordinal: 1 << 8, version: 2, padding: :last }

    map
  end

  def self.encode(data, version: 2)
    case version
    when 1
      emojis = Emojis::V1
      padding_last = PADDING_LAST_V1
      trim = false
    when 2
      emojis = Emojis::V2
      padding_last = PADDING_LAST_V2
      trim = true
    else
      raise Error, 'Version must be either 1 or 2'
    end

    result = []
    data.bytes.each_slice(5) do |s|
      encode_five(s, emojis, padding_last, trim) { |n| result << n }
    end
    result.pack('U*')
  end

  def self.decode(data, encoding: Encoding::UTF_8)
    expected_version = 3
    chars = data.chars
    result = []

    loop do
      emojis, expected_version = read_four(chars, expected_version)
      break if emojis.empty?

      bits = (emojis[0][:ordinal] << 30) |
             (emojis[1][:ordinal] << 20) |
             (emojis[2][:ordinal] << 10) |
             emojis[3][:ordinal]
      out = [
        bits >> 32,
        0xff & (bits >> 24),
        0xff & (bits >> 16),
        0xff & (bits >> 8),
        0xff & bits
      ]

      if emojis[1][:padding] == :fill
        out = out[0...1]
      elsif emojis[2][:padding] == :fill
        out = out[0...2]
      elsif emojis[3][:padding] == :fill
        out = out[0...3]
      elsif emojis[3][:padding] == :last
        out = out[0...4]
      end

      result.concat(out)
    end

    result.pack('C*').force_encoding(encoding)
  end

  private_class_method def self.encode_five(s, emojis, padding_last, trim)
    case s.size
    when 1
      yield emojis[s[0] << 2]
      yield PADDING
      unless trim
        yield PADDING
        yield PADDING
      end
    when 2
      bits = (s[0] << 32) | (s[1] << 24)
      yield emojis[bits >> 30]
      yield emojis[0x3ff & (bits >> 20)]
      yield PADDING
      yield PADDING unless trim
    when 3
      bits = (s[0] << 32) | (s[1] << 24) | (s[2] << 16)
      yield emojis[bits >> 30]
      yield emojis[0x3ff & (bits >> 20)]
      yield emojis[0x3ff & (bits >> 10)]
      yield PADDING
    when 4
      bits = (s[0] << 32) | (s[1] << 24) | (s[2] << 16) | (s[3] << 8)
      yield emojis[bits >> 30]
      yield emojis[0x3ff & (bits >> 20)]
      yield emojis[0x3ff & (bits >> 10)]
      yield padding_last[0x3 & (bits >> 8)]
    when 5
      bits = (s[0] << 32) | (s[1] << 24) | (s[2] << 16) | (s[3] << 8) | s[4]
      yield emojis[bits >> 30]
      yield emojis[0x3ff & (bits >> 20)]
      yield emojis[0x3ff & (bits >> 10)]
      yield emojis[0x3ff & bits]
    else
      raise "BUG: unexpected length: #{s.size}"
    end
  end

  private_class_method def self.read_four(chars, expected_version)
    index = 0
    saw_padding = false
    emojis = [REV_EMOJIS[PADDING], REV_EMOJIS[PADDING], REV_EMOJIS[PADDING], REV_EMOJIS[PADDING]]

    while index < 4
      if chars.empty?
        return [], expected_version if index.zero?
        return emojis, expected_version if saw_padding && [3, 2].include?(expected_version)

        raise Error, 'Unexpected end of data, input data size not multiple of 4'

      end

      c = chars.shift
      next if ["\n", "\r"].include?(c)

      einfo = REV_EMOJIS[c.ord]
      raise Error, "Non Ecoji character seen: #{c.inspect}" unless einfo

      if einfo[:version] != 3
        if expected_version == 3
          expected_version = einfo[:version]
        elsif expected_version != einfo[:version]
          raise Error, "Emojis from different ecoji versions seen: #{c.inspect}"
        end
      end

      case einfo[:padding]
      when :none
        if saw_padding
          raise Error, 'Unexpectedly saw non-padding after padding' unless [3, 2].include?(expected_version)

          chars.unshift(c)
          # NOTE(makenowjust): I think here we should set `expected_version` to `2`,
          # but the original implementation does not.
          # For the compatibility, `expected_version` is kept.
          return emojis, expected_version

        end
      when :fill
        raise Error, 'Padding unexpectedly seen in first position' if index.zero?

        saw_padding = true
      when :last
        raise Error, 'Last padding seen in unexpected position' if index != 3
      end

      emojis[index] = einfo
      index += 1
    end

    [emojis, expected_version]
  end
end
