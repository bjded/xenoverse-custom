#===============================================================================
#  One-shot update notification
#-------------------------------------------------------------------------------
#  The manifest is intentionally small and read once per game process. Network
#  or parsing failures are ignored so the title screen remains usable offline.
#===============================================================================
XENOVERSE_UPDATE_MANIFEST_URL = "https://raw.githubusercontent.com/bjded/xenoverse-custom/main/Xenoverse/UpdateManifest.txt" unless defined?(XENOVERSE_UPDATE_MANIFEST_URL)
XENOVERSE_UPDATE_PAGE_TIMEOUT = 2000 unless defined?(XENOVERSE_UPDATE_PAGE_TIMEOUT)
XENOVERSE_UPDATE_PACKAGE_MAX_BYTES = 524288000 unless defined?(XENOVERSE_UPDATE_PACKAGE_MAX_BYTES)
# Set this to true temporarily to test the title-screen update command locally.
# Test mode does not contact the public manifest.
XENOVERSE_UPDATE_TEST_MODE = false unless defined?(XENOVERSE_UPDATE_TEST_MODE)
XENOVERSE_UPDATE_TEST_VERSION = "1.5.6" unless defined?(XENOVERSE_UPDATE_TEST_VERSION)
XENOVERSE_UPDATE_TEST_URL = "https://github.com/bjded/xenoverse-custom/releases/latest" unless defined?(XENOVERSE_UPDATE_TEST_URL)
XENOVERSE_UPDATE_TEST_DOWNLOAD_URL = "" unless defined?(XENOVERSE_UPDATE_TEST_DOWNLOAD_URL)

class XenoverseUpdateScene
  def initialize
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites={}
    addBackgroundOrColoredPlane(@sprites,"background","loadbg",
      Color.new(248,248,248),@viewport)
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["overlay"].bitmap.font.name="Barlow Condensed"
    @sprites["overlay"].bitmap.font.size=24
    @sprites["overlay"].bitmap.font.bold=true
    update(-1,_INTL("Preparing update..."))
  end

  def update(percent,message)
    percent=-1 if !percent || percent<0
    percent=100 if percent>100
    bitmap=@sprites["overlay"].bitmap
    bitmap.clear
    textColor=Color.new(232,232,232)
    shadowColor=Color.new(136,136,136,0)
    textpos=[
      [_INTL("Xenoverse Update"),Graphics.width/2,72,2,textColor,shadowColor],
      [message,Graphics.width/2,136,2,textColor,shadowColor]
    ]
    pbDrawTextPositions(bitmap,textpos)
    barX=64
    barY=212
    barWidth=384
    barHeight=24
    bitmap.fill_rect(barX-2,barY-2,barWidth+4,barHeight+4,Color.new(232,232,232))
    bitmap.fill_rect(barX,barY,barWidth,barHeight,Color.new(40,40,56))
    if percent>=0
      fillWidth=barWidth*percent/100
      bitmap.fill_rect(barX,barY,fillWidth,barHeight,Color.new(80,210,198)) if fillWidth>0
      pbDrawTextPositions(bitmap,[[
        _INTL("{1}%",percent),Graphics.width/2,260,2,textColor,shadowColor
      ]])
    end
    Graphics.update
    Input.update
  end

  def dispose
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

def pbXenoverseHttpsRequest(url,outputFile=nil,progress=nil,maxBytes=65536)
  return outputFile ? false : "" if !url || !url[/^https:\/\/([^\/]+)(.*)$/]
  host=$1
  path=$2
  path="/" if path==""

  session=nil
  connection=nil
  request=nil
  closeHandle=nil
  output=nil
  success=false
  begin
    openSession=Win32API.new("winhttp","WinHttpOpen","plppl","l")
    setTimeouts=Win32API.new("winhttp","WinHttpSetTimeouts","pllll","l")
    connectHost=Win32API.new("winhttp","WinHttpConnect","ppll","l")
    openRequest=Win32API.new("winhttp","WinHttpOpenRequest","ppppppl","l")
    sendRequest=Win32API.new("winhttp","WinHttpSendRequest","pplplll","l")
    receiveResponse=Win32API.new("winhttp","WinHttpReceiveResponse","pp","l")
    queryData=Win32API.new("winhttp","WinHttpQueryDataAvailable","pp","l")
    readData=Win32API.new("winhttp","WinHttpReadData","pplp","l")
    queryHeaders=Win32API.new("winhttp","WinHttpQueryHeaders","plpppp","l")
    closeHandle=Win32API.new("winhttp","WinHttpCloseHandle","p","l")

    session=openSession.call(to_ws("Xenoverse Update Checker"),0,nil,nil,0)
    return outputFile ? false : "" if !session || session==0
    setTimeouts.call(session,XENOVERSE_UPDATE_PAGE_TIMEOUT,
      XENOVERSE_UPDATE_PAGE_TIMEOUT,XENOVERSE_UPDATE_PAGE_TIMEOUT,
      XENOVERSE_UPDATE_PAGE_TIMEOUT)
    connection=connectHost.call(session,to_ws(host),443,0)
    return outputFile ? false : "" if !connection || connection==0
    request=openRequest.call(connection,to_ws("GET"),to_ws(path),nil,nil,nil,
      0x00800000)
    return outputFile ? false : "" if !request || request==0
    return outputFile ? false : "" if sendRequest.call(request,nil,0,nil,0,0,0)==0
    return outputFile ? false : "" if receiveResponse.call(request,nil)==0

    totalBytes=0
    totalBuffer=[0].pack("L")
    totalLength=[4].pack("L")
    if queryHeaders.call(request,0x20000005,nil,totalBuffer,totalLength,nil)!=0
      totalBytes=totalBuffer.unpack("L")[0]
    end
    return outputFile ? false : "" if totalBytes>maxBytes

    output=File.open(outputFile,"wb") if outputFile
    data=""
    receivedBytes=0
    lastPercent=-2
    progress.call(0) if progress
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
      chunk=buffer[0,count]
      if output
        output.write(chunk)
      else
        data+=chunk
      end
      receivedBytes+=count
      return outputFile ? false : "" if receivedBytes>maxBytes
      if progress
        percent=totalBytes>0 ? (receivedBytes*100/totalBytes) : -1
        if percent!=lastPercent
          progress.call(percent)
          lastPercent=percent
        end
      end
      break if !output && data.length>=maxBytes
    end
    progress.call(100) if progress && totalBytes>0 && lastPercent<100
    success=true
    return outputFile ? true : data[0,maxBytes]
  rescue
    return outputFile ? false : ""
  ensure
    output.close if output
    if outputFile && !success && safeExists?(outputFile)
      begin; File.delete(outputFile); rescue; end
    end
    closeHandle.call(request) if closeHandle && request && request!=0
    closeHandle.call(connection) if closeHandle && connection && connection!=0
    closeHandle.call(session) if closeHandle && session && session!=0
  end
end

def pbXenoverseHttpsGet(url)
  return pbXenoverseHttpsRequest(url,nil,nil,65536)
end

def pbXenoverseDownloadFile(url,filename,progress=nil)
  return pbXenoverseHttpsRequest(url,filename,progress,XENOVERSE_UPDATE_PACKAGE_MAX_BYTES)
end

def pbXenoverseParseUpdateManifest(manifest)
  return nil if !manifest || manifest==""
  versionText=nil
  updateUrl=nil
  downloadUrl=nil
  manifest.to_s.split(/\r?\n/).each do |line|
    line=line.strip
    next if line=="" || line[0,1]=="#"
    versionText=$1 if line[/^version\s*=\s*([0-9]+(?:\.[0-9]+)*)$/]
    updateUrl=$1 if line[/^url\s*=\s*(https:\/\/\S+)$/]
    downloadUrl=$1 if line[/^download\s*=\s*(https:\/\/\S+)$/]
  end
  return nil if !versionText || !updateUrl
  begin
    remoteVersion=Version.new(versionText)
    return nil if !(remoteVersion>GAME_VERSION)
  rescue
    return nil
  end
  return {:version=>versionText,:url=>updateUrl,:download=>downloadUrl}
end

module XenoverseUpdate
  @checked=false
  @available=nil

  def self.check
    return @available if @checked
    @checked=true
    if XENOVERSE_UPDATE_TEST_MODE
      @available={:version=>XENOVERSE_UPDATE_TEST_VERSION,:url=>XENOVERSE_UPDATE_TEST_URL,
        :download=>XENOVERSE_UPDATE_TEST_DOWNLOAD_URL}
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

def pbXenoverseQuoteWindowsArgument(value)
  return "\""+value.to_s+"\""
end

def pbXenoverseLaunchUpdater(packagePath)
  updaterPath=File.expand_path("UpdateGame.ps1")
  gameDirectory=File.expand_path(".")
  gameExecutable=File.expand_path("Game.exe")
  return false if !safeExists?(updaterPath) || !safeExists?(gameExecutable)
  begin
    processId=Win32API.new("kernel32","GetCurrentProcessId","","l").call
    parameters="-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "+
      pbXenoverseQuoteWindowsArgument(updaterPath)+
      " -GameDirectory "+pbXenoverseQuoteWindowsArgument(gameDirectory)+
      " -PackagePath "+pbXenoverseQuoteWindowsArgument(packagePath)+
      " -ProcessId "+processId.to_s+
      " -GameExecutable "+pbXenoverseQuoteWindowsArgument(gameExecutable)
    shellExecute=Win32API.new("shell32.dll","ShellExecuteW","lppppl","l")
    return shellExecute.call(0,to_ws("open"),to_ws("powershell.exe"),
      to_ws(parameters),nil,0)>32
  rescue
    return false
  end
end

def pbXenoverseDownloadAndLaunchUpdate(url)
  return false if !url || url==""
  tempDirectory=ENV["TEMP"] || ENV["TMP"] || "."
  processId=Win32API.new("kernel32","GetCurrentProcessId","","l").call rescue 0
  packagePath=File.join(tempDirectory,
    "Xenoverse-update-#{processId}-#{Time.now.to_i}.zip")
  scene=nil
  launched=false
  begin
    scene=XenoverseUpdateScene.new
    progress=proc do |percent|
      message=percent<0 ? _INTL("Downloading update...") :
        _INTL("Downloading update... {1}%",percent)
      scene.update(percent,message)
    end
    if pbXenoverseDownloadFile(url,packagePath,progress)
      scene.update(100,_INTL("Restarting to apply update..."))
      launched=pbXenoverseLaunchUpdater(packagePath)
    end
  rescue
    launched=false
  ensure
    scene.dispose if scene
    if !launched && safeExists?(packagePath)
      begin; File.delete(packagePath); rescue; end
    end
  end
  return launched
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
