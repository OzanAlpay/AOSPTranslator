# AOSPTranslator
Ruby script to make translations between languages easier especially for AOSP projects<br />
It has two different modes :
First finding differences/items that needs translation for a selected language<br />



In Finding Differences mode:<br />
Script will find ids of elements that need translation<br />
1-You must run script from your res folder.<br />
2-It requires two extra parameters , Language code , that you want to translate your project [as language code tr -> Turkish etc]<br />
3-And as a second parameter you should give an item-type.<br />
4-Script will create an Excel file that contains missing elements in given language, their english values and their ids.<br />
You can find structure of this file below.<br />
According to your parameters it will create an excel file , which has three columns<br />
|--------- ID ---------- | --------- English -------------- | -- input_lang --|<br />
| Id of missing element  | English value of missing element |     Empty       |<br />

Example : StringParser.rb diff tr string<br />

Currently supported element types<br />
string, string-array and plurals[experimental, not available in transfer mode]<br />

Second mode is Add Translations according to element name and id

In Transfer Translations mode:<br />
In this mode Script will read translated values, and automatically puts them into related files.<br />
1-You must run script from res folder and also excel file that contains translations must be in the res folder.<br />
2-It requires two parameters first language-code and then item type ex StringParser.rb transfer tr string<br />
3-And you must provide an excel file that saved in .xls format. If you get an error about OLE2 , please save it again<br />
Microsoft Excel 97/2000/XP/2000 format and try again.<br />
4-Your excel file structure must like: -> just similar to you created in Finding Differences Mode<br />
|--------- ID ---------- | --------- English -------------- | -- input_lang  --|<br />
| Id of missing element  | English value of missing element | -- Translation --|<br />

It will read through excel file and create elements automatically.<br />

TODO<br />
FATAL : xliffg problem -> FIXED ON 20.03.2017<br>
FATAL : We need support for plurals <br>
Add more supported element types<br />
Support different file extensions<br />
Bugfixing.<br />


