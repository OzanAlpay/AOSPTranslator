# AOSPTranslator
Ruby script to make translations between languages easier especially for AOSP projects
It has two different modes : First finding differences , or find missing translations for a selected language


In Finding Differences mode:
Script will find ids of elements that need translation
1-You must run script from your res folder.
2-It requires two extra parameters , Language code , that you want to translate your project [as language code tr -> Turkish etc]
3-And as a second parameter you should give an item-type.
4-Script will create an Excel file that contains missing elements in given language, their english values and their ids.
You can find structure of this file below.
According to your parameters it will create an excel file , which has three columns
|--------- ID ---------- | --------- English -------------- | -- input_lang --|
| Id of missing element  | English value of missing element |     Empty       |

Example : StringParser.rb diff tr string

Currently supported element types
string, string-array

In Transfer Translations mode:
In this mode Script will read translated values, and automatically puts them into related files.
1-You must run script from res folder and also excel file that contains translations must be in the res folder.
2-It requires two parameters first language-code and then item type ex StringParser.rb transfer tr string
3-And you must provide an excel file that saved in .xls format. If you get an error about OLE2 , please save it again
Microsoft Excel 97/2000/XP/2000 format and try again.
4-Your excel file structure must like: -> just similar to you created in Finding Differences Mode
|--------- ID ---------- | --------- English -------------- | -- input_lang  --|
| Id of missing element  | English value of missing element | -- Translation --|

It will read through excel file and create elements automatically.

TODO
Add more supported element types
Support different file extensions
Bugfixing.


