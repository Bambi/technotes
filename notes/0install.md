# 0install
Use feed files (XML) to define program installation. Programs are installed in a cache
(private or shared) and downloaded or updated automatically.

## Application install
Run a program directly: `0install run <feed>`

Create an alias (application): `0install add <app> <feed>`

## Packaging
Use 0publish: `0install add 0publish https://apps.0install.net/0install/0publish.xml`.
You will also need a gpg key for signing.

First create a new feed with `0publish app.xml`.

Download the app you want to publish. Then add a new release with:
```
0publish prog.xml --set-version=<vers> --set-released=<rel date>
    --archive-url=<download url> --archive-file=<downloaded arch file>
    --archive-extract=<extract dir>
```
You should then be able to run your program with `0install run ./app.xml`.
Set the interface url with `0publish --set-interface-uri=https://bambi.github.io/0install-feeds/app.xml`.
And sign it: `0publish app.xml --xmlsign`.

For an other release, repeat the process but use `--add-version` instead of `--set-version`.

## Packaging With Template
Use 0template: `0install add 0template https://apps.0install.net/0install/0template.xml`

The point is to make a template for a feed which will be instantiated for each
new release.

Generate e new template: `0template myprog.xml.template`

Generate a new version: `0template myprog.xml.template version=1.0`
