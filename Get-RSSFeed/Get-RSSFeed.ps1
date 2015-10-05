<#
.Synopsis
   RSS Reader for Powershell October 2015 Scripting Games
.DESCRIPTION
     Given a link to a rss feed(s) this will output the Headline. While not presented by default the object also
    includes the publication date if the feed provides it. This will allow you to sort the return by date and time 
    if needed.
.PARAMETER URI
    URIs for RSS feeds
    This is a mandatory parameter
    This patameter is supported from the pipeline
.PARAMETER ShowLink
    Switch parameter to show the link to the feed article
    Default value is False
.PARAMETER ShowDescription
    Switch parameter to show the description of the article
    Default value is False
    Not all feeds publish a description
.PARAMETER UriVerification
    Switch parameter to verify the uri is a vaild rss feed
    Default value is False
    When enabled the uri is checked via The Feed validation Service https://validator.w3.org/
.INPUTS
    String
.OUTPUTS
    PSCustomObject
.EXAMPLE
   Get-RSSFeed -uri "http://rss.cnn.com/rss/cnn_topstories.rss"
   Retrives the Top Stories feed from CNN and outputs the Headline of each.
.EXAMPLE
   Get-RSSFeed -uri "http://rss.cnn.com/rss/cnn_topstories.rss" -ShowLink
   Retrives the Top Stories feed from CNN and outputs the Headline and Link of each article.
.EXAMPLE
   Get-RSSFeed -uri "http://rss.cnn.com/rss/cnn_topstories.rss" -ShowDescription
   Retrives the Top Stories feed from CNN and outputs the Headline and description of each article.
.EXAMPLE
   Get-RSSFeed -uri "http://rss.cnn.com/rss/cnn_topstories.rss" -UriVerification
   Verifies that the feed is vaild. 
   If the feed passes verification then retrives the Top Stories feed from CNN and outputs the Headline of each.
.EXAMPLE
   "http://rss.cnn.com/rss/cnn_topstories.rss"|Get-RSSFeed -ShowLink -ShowDescription|Export-Csv -Path D:\test\test.csv -NoTypeInformation
   Retrives the Top Stories feed from CNN and outputs the Headline, Link, and Description and exports the output as a .csv file
   Note that the PubDate (Publication Date) from the feed (if available) is also included in the .csv file.
.EXAMPLE
   Get-RSSFeed -uri "http://rss.cnn.com/rss/cnn_topstories.rss"|format-list -Property * -Force
   Retrives the Top Stories feed from CNN and outputs the Headline of each and the PubDate in list format. 
.NOTES
    Author
        Jonathan Warnken
        @MrBoDean
        jon.warnken@gmail.com
    License
        The MIT License (MIT)

        Copyright (c) 2015 Jonathan Warnken

        Permission is hereby granted, free of charge, to any person obtaining a copy
        of this software and associated documentation files (the "Software"), to deal
        in the Software without restriction, including without limitation the rights
        to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
        copies of the Software, and to permit persons to whom the Software is
        furnished to do so, subject to the following conditions:

        The above copyright notice and this permission notice shall be included in all
        copies or substantial portions of the Software.

        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
        IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
        FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
        AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
        LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
        OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
        SOFTWARE.
#>
function Get-RSSFeed
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [String]$Uri,
        [Switch]$ShowLink=$false,
        [Switch]$ShowDescription=$false,
        [Switch]$UriVerification=$false
    )

    Begin{}#Begin
    Process{
        Foreach($link in $uri){
            if($UriVerification){
			    #Sleep for 1 second to honor the request of the free public Feed Validation service (https://validator.w3.org/)
                Start-Sleep -Seconds 1
                #Ensure we have a vaild feed
                Try{
                    [xml]$Verify = (Invoke-WebRequest -Uri "https://validator.w3.org/feed/check.cgi?output=soap12&url=$link").Content
                    If($Verify.Envelope.Body.feedvalidationresponse.errors.errorcount -ne 0){
                        Throw "Failed - $link is not a vaild rss feed."
                    }#If
                }#try
                Catch [System.Net.WebException]{ 
                    Throw "Failed - Ensure $link is correct and is a vaild rss feed."               
                }#catch
            }#If
            #If($Verification -ne "Failed - Ensure $link is correct and is a vaild rss feed."){
                
                    $Verification = "Success"
                    [xml]$feed = Invoke-WebRequest -Uri $link
                    Foreach($item in $feed.rss.channel.item){
                        if($item.title -ne $null){
                            $return =[PSCustomObject]@{
                                'HeadLine' = $item.title
                                'PubDate' = $item.pubdate
                            }#[PSCustomObject]@
                            If($ShowLink){Add-Member -InputObject $return -MemberType NoteProperty -Name "Link" -Value $item.Link }
                            If($ShowDescription){Add-Member -InputObject $return -MemberType NoteProperty -Name "Description" -Value ($item.description).innertext }
                            $defaultProperties = @('HeadLine','Link','Description')
                            $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet(‘DefaultDisplayPropertySet’,[string[]]$defaultProperties)
                            $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
                            $return | Add-Member MemberSet PSStandardMembers $PSStandardMembers
                            $return
                        }#If
                    }#Foreach
            #}#If Else
        }#Foreach
    }#Process
    End{}#End
}