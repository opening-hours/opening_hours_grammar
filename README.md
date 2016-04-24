# opening_hours_grammar
ANTLR grammar for opening_hours from OpenStreetMap

## Limitations and trade offs
* No deep semantic ATM ("14:00-12:00" is "okay") because first iterations should be flexible
* No soft error checking like in OH library (HTML-like parsing "Oh you did mistake here, let me fix this for you" is not goal of this project); because it will bloat grammar in every aspect direction
* Restrictive syntax, when it comes to WS (simpler AST, faster parsing I guess)

## Contributing 
### How to use
#### IDE
* http://www.antlr.org/tools.html

#### Command line 
* http://www.antlr.org/index.html

### How to develop 

* https://github.com/antlr/antlr4/blob/master/doc/index.md
* https://github.com/antlr/antlr4/blob/master/doc/lexer-rules.md
* https://github.com/antlr/antlr4/blob/master/doc/parser-rules.md
