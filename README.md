## opening_hours_grammar
ANTLR grammar for opening_hours from OpenStreetMap

#### Limitations and trade offs
* No deep semantic ATM ("14:00-12:00" is "okay") because first iterations should be flexible
* There no [linter](https://en.wikipedia.org/wiki/Lint_%28software%29) YET. No soft error checking in **min**imal version, like [opening_hours.js](https://github.com/opening-hours/opening_hours.js) (HTML-like parsing "Oh you did mistake here, let me fix this for you" is not goal of this project); because it will bloat grammar in every aspect and direction.
* Multiple versions of grammar (more/less restrictive) may occur over time.

### Contributing 
#### How to use
##### IDE
* IDEA https://github.com/antlr/intellij-plugin-v4#intellij-idea-plugin-for-antlr-v4
* Eclipse https://github.com/jknack/antlr4ide#requirements
* VS https://visualstudiogallery.msdn.microsoft.com/25b991db-befd-441b-b23b-bb5f8d07ee9f

##### Command line 
* http://www.antlr.org/index.html

#### How to develop 

* https://github.com/antlr/antlr4/blob/master/doc/index.md
* https://github.com/antlr/antlr4/blob/master/doc/lexer-rules.md
* https://github.com/antlr/antlr4/blob/master/doc/parser-rules.md
