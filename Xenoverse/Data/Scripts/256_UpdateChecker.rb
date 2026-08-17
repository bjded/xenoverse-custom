#===============================================================================
#  One-shot update notification
#-------------------------------------------------------------------------------
#  The manifest is intentionally small and read once per game process. Network
#  or parsing failures are ignored so the title screen remains usable offline.
#===============================================================================
XENOVERSE_UPDATE_MANIFEST_URL = "https://raw.githubusercontent.com/bjded/xenoverse-custom/main/Xenoverse/UpdateManifest.txt" unless defined?(XENOVERSE_UPDATE_MANIFEST_URL)
XENOVERSE_UPDATE_PAGE_TIMEOUT = 2000 unless defined?(XENOVERSE_UPDATE_PAGE_TIMEOUT)
# Set this to true temporarily to test the title-screen update command locally.
# Test mode does not contact the public manifest.
XENOVERSE_UPDATE_TEST_MODE = false unless defined?(XENOVERSE_UPDATE_TEST_MODE)
XENOVERSE_UPDATE_TEST_VERSION = "1.5.6" unless defined?(XENOVERSE_UPDATE_TEST_VERSION)
XENOVERSE_UPDATE_TEST_URL = "https://github.com/bjded/xenoverse-custom/releases/latest" unless defined?(XENOVERSE_UPDATE_TEST_URL)

def pbXenoverseHttpsGet(url)
  return "" if !url || !url[/^https:\/\/([^\/]+)(.*)$/]
  host=$1
  path=$2
  path="/" if path==""

  session=nil
  connection=nil
  request=nil
  closeHandle=nil
  begin
    openSession=Win32API.new("winhttp","WinHttpOpen","plppl","l")
    setTimeouts=Win32API.new("winhttp","WinHttpSetTimeouts","pllll","l")
    connectHost=Win32API.new("winhttp","WinHttpConnect","ppll","l")
    openRequest=Win32API.new("winhttp","WinHttpOpenRequest","ppppppl","l")
    sendRequest=Win32API.new("winhttp","WinHttpSendRequest","pplplll","l")
    receiveResponse=Win32API.new("winhttp","WinHttpReceiveResponse","pp","l")
    queryData=Win32API.new("winhttp","WinHttpQueryDataAvailable","pp","l")
    readData=Win32API.new("winhttp","WinHttpReadData","pplp","l")
    closeHandle=Win32API.new("winhttp","WinHttpCloseHandle","p","l")

    session=openSession.call(to_ws("Xenoverse Update Checker"),0,nil,nil,0)
    return "" if !session || session==0
    setTimeouts.call(session,XENOVERSE_UPDATE_PAGE_TIMEOUT,
      XENOVERSE_UPDATE_PAGE_TIMEOUT,XENOVERSE_UPDATE_PAGE_TIMEOUT,
      XENOVERSE_UPDATE_PAGE_TIMEOUT)
    connection=connectHost.call(session,to_ws(host),443,0)
    return "" if !connection || connection==0
    request=openRequest.call(connection,to_ws("GET"),to_ws(path),nil,nil,nil,
      0x00800000)
    return "" if !request || request==0
    return "" if sendRequest.call(request,nil,0,nil,0,0,0)==0
    return "" if receiveResponse.call(request,nil)==0

    data=""
    loop do
      availableBytes=[0].pack("L")
      break if queryData.call(request,availableBytes)==0
      available=availableBytes.unpack("L")[0]
      break if !available || available<=0
      readSize=[available,65536].min
      buffer="\0"*readSize
      readBytes=[0].pack("L")
      break if readData.call(request,buffer,readSize,readBytes)==0
      count=readBytes.unpack("L")[0]
      break if !count || count<=0
      data+=buffer[0,count]
      break if data.length>65536
    end
    return data[0,65536]
  rescue
    return ""
  ensure
    closeHandle.call(request) if closeHandle && request && request!=0
    closeHandle.call(connection) if closeHandle && connection && connection!=0
    closeHandle.call(session) if closeHandle && session && session!=0
  end
end

def pbXenoverseParseUpdateManifest(manifest)
  return nil if !manifest || manifest==""
  versionText=nil
  updateUrl=nil
  manifest.to_s.split(/\r?\n/).each do |line|
    line=line.strip
    next if line=="" || line[0,1]=="#"
    versionText=$1 if line[/^version\s*=\s*([0-9]+(?:\.[0-9]+)*)$/]
    updateUrl=$1 if line[/^url\s*=\s*(https:\/\/\S+)$/]
  end
  return nil if !versionText || !updateUrl
  begin
    remoteVersion=Version.new(versionText)
    return nil if !(remoteVersion>GAME_VERSION)
  rescue
    return nil
  end
  return {:version=>versionText,:url=>updateUrl}
end

module XenoverseUpdate
  @checked=false
  @available=nil

  def self.check
    return @available if @checked
    @checked=true
    if XENOVERSE_UPDATE_TEST_MODE
      @available={:version=>XENOVERSE_UPDATE_TEST_VERSION,:url=>XENOVERSE_UPDATE_TEST_URL}
      return @available
    end
    manifest=pbXenoverseHttpsGet(XENOVERSE_UPDATE_MANIFEST_URL)
    @available=pbXenoverseParseUpdateManifest(manifest)
    return @available
  rescue
    @available=nil
    return @available
  end
end

def pbXenoverseCheckForUpdate
  return XenoverseUpdate.check
end

def pbXenoverseOpenUpdatePage(url)
  return false if !url || url==""
  begin
    shellExecute=Win32API.new("shell32.dll","ShellExecuteA","lppppl","l")
    return shellExecute.call(0,"open",url,nil,nil,1)>32
  rescue
    return false
  end
end
