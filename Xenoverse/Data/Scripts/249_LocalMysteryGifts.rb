# Local Mystery Gift catalog for the offline build.
# Published codes are transcribed from the available reward cards. Cards without
# a published code use a local TW1TCH_<VARIANT>_<SPECIES> alias.
# Unknown codes still use the original remote path.

LOCAL_MYSTERY_GIFTS_ENABLED = true unless defined?(LOCAL_MYSTERY_GIFTS_ENABLED)

module LocalMysteryGifts
  FILE = "Data/MysteryGifts.csv"

  def self.records
    return @records if @records

    @records = {}
    begin
      file = File.open(FILE, "rb")
      header = nil
      while line = file.gets
        line.chomp!
        next if line == "" || line[0,1] == "#"

        if header == nil
          header = line.split(",", -1)
          next
        end

        values = line.split(",", -1)
        record = {}
        for i in 0...header.length
          record[header[i]] = values[i] || ""
        end
        @records[record["code"].upcase] = record if record["code"] && record["code"] != ""
      end
      file.close
    rescue
      @records = {}
    end
    return @records
  end

  def self.record(code)
    return nil if !LOCAL_MYSTERY_GIFTS_ENABLED
    return records[code.to_s.upcase]
  end

  def self.response(record, requested_code=nil)
    # Preserve the existing 14-field wire format so the normal parser is tested.
    # Leave OT and nickname unset: the game assigns the current trainer as OT
    # and keeps the normal species-name display when no nickname is supplied.
    ivs = []
    6.times { ivs.push(rand(32)) }
    evs = "0|0|0|0|0|0"
    moves = "NIL|NIL|NIL|NIL"

    gender_policy = record["gender_policy"]
    if gender_policy == "random"
      gender = rand(2)
    elsif gender_policy == "genderless"
      gender = 2
    else
      gender = gender_policy.to_i
    end

    values = [
      requested_code || record["code"],
      record["species"],
      record["level"],
      record["shiny"],
      "NIL",
      record["ball"],
      record["item"],
      ivs.join("|"),
      evs,
      moves,
      record["ability"],
      "NIL",
      gender.to_s,
      record["form"]
    ]
    return values.join("</s>")
  end
end

class Database
  class << self
    alias_method :local_mock_remote_exists, :exists
    alias_method :local_mock_remote_request_gift, :requestGift

    def exists(type, code, data={})
      return "true" if type == "checkCode" && LocalMysteryGifts.record(code)
      return local_mock_remote_exists(type, code, data)
    end

    def requestGift(type, code, data={})
      local = LocalMysteryGifts.record(code)
      return LocalMysteryGifts.response(local, code) if type == "getGifts" && local
      return local_mock_remote_request_gift(type, code, data)
    end
  end
end
