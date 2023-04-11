# `fizztool`

`fizztool` is a simple command-line tool that does the following:

- Writes informational messages, such as banner text, progress, etc. to stderr
- Writes error messages to stderr
  - Error messages should be easily distinguished from informational messages and banner text
- Writes successful output to stdout
  - Success output should be a JSON object containing simple key-value pairs

## Successful example

Here is an example invocation of the tool that should succeed:

```sh
fizztool.exe --key fizz
```

The copyright line is written to stderr, and the JSON object is written to stdout.

```Output
fizztool.exe v1.0.0 (c) 2021 Tailspin Toys, Ltd.

{
    "fizz": "buzz"
}
```

If you run it from PowerShell, the you see the following output:

```powershell
fizztool.exe --key fizz | ConvertFrom-Json
```

```Output
fizztool.exe v1.0.0 (c) 2021 Tailspin Toys, Ltd.

fizz
----
buzz
```

## Failure example

Here is an example invocation of the tool that should fail:

```sh
fizztool.exe --key buzz
```

```Output
fizztool.exe v1.0.0 (c) 2021 Tailspin Toys, Ltd.
ERROR: Key not found: buzz
```

If you run it from PowerShell, then you see the following output:

```powershell
fizztool.exe --key buzz | ConvertFrom-Json
```

```Output
fizztool.exe v1.0.0 (c) 2021 Tailspin Toys, Ltd.
ERROR: Key not found: buzz
```
