# google-java-format formatter
1. read [https://github.com/google/google-java-format](https://github.com/google/google-java-format)
2. download [https://github.com/google/google-java-format/releases](https://github.com/google/google-java-format/releases) in `eclipse/dropins/` folder
3. Window > Preferences > Java > Code Style > Formatter > Formatter Implementation
4. `eclipse.ini` add the following
```
    --add-exports=jdk.compiler/com.sun.tools.javac.api=ALL-UNNAMED
    --add-exports=jdk.compiler/com.sun.tools.javac.code=ALL-UNNAMED
    --add-exports=jdk.compiler/com.sun.tools.javac.file=ALL-UNNAMED
    --add-exports=jdk.compiler/com.sun.tools.javac.parser=ALL-UNNAMED
    --add-exports=jdk.compiler/com.sun.tools.javac.tree=ALL-UNNAMED
    --add-exports=jdk.compiler/com.sun.tools.javac.util=ALL-UNNAMED
```
