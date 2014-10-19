Pair
====

# What is it for?
Pair is a PowerShell module. It allows you to quickly change the git user name and email to contain the names of people pairing. Those name and email will be attached to all commits made before the pair is changed.


Compatible with PowerShell 2+.

##Spec
&nbsp; | &nbsp;
------ | -----
| Given | John Doe and Jack Common are pairing today |
| And   | they're logged in with user name "HAL1" |
| And   | their aliases are "jd" and "jc" |
| And   | their base email is "department@company.com" |
| When  | they type "pair jd jc" |
| Then  | the git name is set to "John Doe and Jack Common on HAL1" |
| And   | the git email is set to "department+jd+jc@company.com" |
| And   | all of their further commits will contain those name and email |

# How to set Pair up?
1. Install it [as any other PowerShell module] (http://msdn.microsoft.com/en-us/library/dd878350(v=vs.85).aspx). On PowerShell 3+ that usually means clone it to `$HOME\Documents\WindowsPowerShell\Modules`. If any folders in that path don't exist, create them. On PowerShell 2 you'll have to Import-Module the folder every time :/ You can do that from your profile script.
2. Create a coma separated file to match aliases to full names. An example [is included in the repo itself] (https://github.com/aulme/Pair/blob/master/defaultPairFile.csv). I suggest you sync that between machines.
3. Run `Set-PairFile C:\my\pair\file\path.csv`, with the path of your new file
4. Run `Set-BaseEmail department@company.com`, pair emails will be constructed from that.

# How to use Pair?
1. `pair` will show you the current pair with full names.
2. `pair john jack` will set John and Jack as the current pair as long they're in the pair file
3. `Get-PairAliases` will get you just the aliases of the people currently pairing. I include this in my prompt.
