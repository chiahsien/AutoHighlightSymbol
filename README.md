Auto Highlight Symbol
=====================

Xcode can highlight instances of selected symbol, but what it does is to add dash lines under the instances, which is hard to be noticed.

AutoHighlightSymbol is a plugin for Xcode, it adds background highlight color to those instances. It's super useful while you're tracing codes, especially when you want to figure out where a specific varible is used in a certain method.

This plugin is still in early beta, you're welcome to improve it and send me pull requests.

**NOTICE**:

You need to enable *Highlight instances of selected symbol* option first from *Xcode preferences -> Text Editing*.

Screenshots
-----------

![](./screenshot.png)

Installation
------------
- Download the sources, build the project and restart Xcode.

- If you encounter any issues you can uninstall it by removing the ~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/AutoHighlightSymbol.xcplugin folder.

Todo
----
- [ ] Integrate into [Alcatraz](https://github.com/supermarin/Alcatraz)
- [ ] Better highlight detection mechanism
- [ ] Better highlight rendering mechanism

License
-------
AutoHighlightSymbol is available under the MIT license. See the LICENSE file for more info.

Contact
-------
Any suggestions or improvements are more than welcome. Feel free to contact me at [chiahsien@gmail.com](mailto:chiahsien@gmail.com) or [@NelsonT](https://twitter.com/NelsonT).

Thanks
------
AutoHighlightSymbol cannot be done without these great plugins.

- [SCXcodeMiniMap](https://github.com/stefanceriu/SCXcodeMiniMap)
- [HighlightSelectedString](https://github.com/keepyounger/HighlightSelectedString)
- [XcodeBoost](https://github.com/fortinmike/XcodeBoost)

And these great articles.

- [How To Create an Xcode Plugin](http://www.raywenderlich.com/94020/creating-an-xcode-plugin-part-1)
- [Xcode 4 插件制作入门](http://www.onevcat.com/2013/02/xcode-plugin/)
