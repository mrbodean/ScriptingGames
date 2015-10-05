$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "Get-RSSFeed" {
    It "retrives a feed" {
        $uris = "http://rss.cnn.com/rss/cnn_topstories.rss","http://ww.npr.org/rss/rss.php?id=1001","https://technet.microsoft.com/en-us/security/rss/bulletin"
        foreach($uri in $uris){
            $result = Get-RSSFeed -uri $uri
            $result.HeadLine| Should Not Be $null
        }
    }
    It "processes uri with a WebException" {
        $uri = "http://www.powershell.org"
        {Get-RSSFeed -uri $uri -UriVerification } |Should Throw "Failed - Ensure $uri is correct and is a vaild rss feed."
    }
    It "find invaild feeds"{
        $uri = "http://www.powershell.org/"
        {Get-RSSFeed -uri $uri -UriVerification}|Should Throw "Failed - $uri is not a vaild rss feed."
    }
    It "gets the link" {
        $uris = "http://rss.cnn.com/rss/cnn_topstories.rss","http://ww.npr.org/rss/rss.php?id=1001","https://technet.microsoft.com/en-us/security/rss/bulletin"
        foreach($uri in $uris){
            $result = Get-RSSFeed -uri $uri -ShowLink
            $result.Link| Should Not Be $null
        }
    }
    It "gets the description" {
        $uri = "http://www.powershell.org/feed"
        $result = Get-RSSFeed -uri $uri -ShowDescription
        $result.Description| Should Be $true 
    }
}
