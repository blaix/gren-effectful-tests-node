# Gren Effectful Test Runner

Run [Gren](https://gren-lang.org/) integration tests that depend on the actual results of [tasks](https://gren-lang.org/book/applications/tasks/).

See the full API on [the package site](https://packages.gren-lang.org/package/blaix/gren-effectful-tests-node).

## Quick Start

Create a directory for your tests and initialize a gren program targeting node:

```sh
mkdir tests
cd tests
gren init --platform=node
```

Install the package:

```sh
gren package install blaix/gren-effectful-tests-node
```

Create a `src/Main.gren` with your tests.
See the [examples below](#Examples),
the working example [in the repo](https://github.com/blaix/gren-effectful-tests-node/blob/main/example/src/Main.gren),
or [the package docs](https://packages.gren-lang.org/package/blaix/gren-effectful-tests-node)
for how to do that.

Then compile and run your tests:

```
gren make src/Main.gren
node app
```

## Examples

Your test runner should be a [Node.SimpleProgram](https://packages.gren-lang.org/package/gren-lang/node/version/latest/module/Node#defineSimpleProgram)
that calls `run` on your test suite.

This package provides wrappers for the normal [gren-lang/test](https://packages.gren-lang.org/package/gren-lang/test)
functions to define your test suite.
Plus additional functions like `await` that let you resolve tasks.

### Basic test

A basic test that awaits a task:

```elm
import Expect
import Node
import Test.Runner.Effectful exposing (run, test, await)
import Time

main : Effectful.Program a
main = 
    Node.defineSimpleProgram <| \env ->
        run env <|
            await Time.now "the current time" <| \now ->
                test "is not Jan 1, 1970" <| \_ ->
                    Expect.notEqual (Time.millisToPosix 0) now
```

### Errors

If you try to await a task that fails, the test run will fail.

If you want to explicitly test the failure condition, use `awaitError`:

```elm
import Expect
import Test.Runner.Effectful exposing (run, test, awaitError)

main : Effectful.Program a
main = 
    Node.defineSimpleProgram <| \env ->
        run env <|
            awaitError (Task.fail "oopsy") "expected failure" <| \error ->
                test "is an oopsy" <| \_ ->
                    Expect.equal "oopsy" error
```

### Nested awaits

You can nest awaits as deep as you need:

```
run env <|
    await (Task.succeed "a") "task a" <| \a ->
    await (Task.succeed "b") "task b" <| \b ->
    awaitError (Task.fail "failure") "failed task" <| \error ->
        test "nested tasks" <| \_ ->
            Expect.equalArrays
                [ "a", "b", "error" ]
                [ a, b, error ]
```

### Subsystems

Because your runner is a normal gren node program, you have access to 
[subsystem permissions](https://packages.gren-lang.org/package/gren-lang/node/version/latest/module/Init)
if you need them:

```elm
import Bytes
import Expect
import FileSystem
import Test.Runner.Effectful exposing (run, describe, test, await)


main : Effectful.Program a
main = 
    Node.defineSimpleProgram <| \env ->
        Init.await FileSystem.initialize <| \fsPerm->
        Init.await ChildProcess.initialize <| \processPerm ->
            run env <|
                describe "my effectful tests"
                    [ await (readTestFile fsPerm) "reading test.txt" <| \contents ->
                        test "resolves to contents of file" <| \_ ->
                            Expect.equal (Just "some text\n") content
                    , await (catTestFile processPerm) "cat test.txt" <| \contents ->
                        test "also resolves to contents of file" <| \_ ->
                            Expect.equal (Just "some text\n") content
                    ]


readTestFile : FileSystem.Permission -> Task FileSystem.Error (Maybe String)
readTestFile permission =
    "./test.txt"
        |> Path.fromPosixString
        |> FileSystem.readFile permission
        |> Task.map Bytes.toString


catTestFile : ChildProcess.Permission -> Task ChildProcess.FailedRun (Maybe String)
catTestFile permission =
    ChildProcess.run permission "cat" [ "test.txt" ] ChildProcess.defaultRunOptions
        |> Task.map .stdout
        |> Task.map Bytes.toString
```

## Contact

Found a problem? Need some help?
You can [open an issue](https://github.com/blaix/gren-effectful-tests-node/issues),
find me [on mastodon](https://hachyderm.io/@blaix),
or on the [Gren Discord](https://gren-lang.org/community).
