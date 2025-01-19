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

Install the necessary packages:

```sh
gren package install gren-lang/test
gren package install blaix/gren-effectful-tests-node
```

Create a `src/Main.gren` with your tests.
See the [examples below](#Examples) or the working example [in the repo](https://github.com/blaix/gren-effectful-tests-node/blob/main/example/src/Main.gren)
for how to do that.

Then compile and run your tests:

```
gren make src/Main.gren
node app
```

## Examples

This package provides wrappers for the normal [gren-lang/test](https://packages.gren-lang.org/package/gren-lang/test)
functions, so you have access to the full gren test API.

### Basic test

The basic functions you'll need to write a test that waits for a task are
[run](https://packages.gren-lang.org/package/blaix/gren-effectful-tests-node/version/latest/module/Test.Runner.Effectful#run) and [await](https://packages.gren-lang.org/package/blaix/gren-effectful-tests-node/version/latest/module/Test.Runner.Effectful#await)

In the body of the await callback,
you can construct a test using any of the functions in the 
[gren-lang/test](https://packages.gren-lang.org/package/gren-lang/test) package.

```elm
import Expect
import Test exposing (test)
import Test.Runner.Effectful exposing (run, await)
import Time

main = 
    run <|
        await Time.now "the current time" <| \now ->
            test "is not Jan 1, 1970" <| \_ ->
                Expect.notEqual (Time.millisToPosix 0) now
```

### Errors

If you try to [await](https://packages.gren-lang.org/package/blaix/gren-effectful-tests-node/version/latest/module/Test.Runner.Effectful#await)
a task that fails, the test run will fail.

If you want to explicitly test the failure condition,
use [awaitError](https://packages.gren-lang.org/package/blaix/gren-effectful-tests-node/version/latest/module/Test.Runner.Effectful#await):

```elm
import Expect
import Test exposing (test)
import Test.Runner.Effectful exposing (run, awaitError)

main = 
    run <|
        awaitError (Task.fail "oopsy") "task that I expect to fail" <| \error ->
            test "is an oopsy" <| \_ ->
                Expect.equal "oopsy" error
```

### Running multiple tests

You can run an array of effectful tests with 
[join](https://packages.gren-lang.org/package/blaix/gren-effectful-tests-node/version/latest/module/Test.Runner.Effectful#join):


```elm
import Expect
import Test exposing (test)
import Test.Runner.Effectful exposing (run, await, join)
import Time

main = 
    run <|
        join
            [ await Time.now "the current time" <| \now ->
                test "is not Jan 1, 1970" <| \_ ->
                    Expect.notEqual (Time.millisToPosix 0) now
            , await (Task.succeed "hey") "my other task" <| \val ->
                test "is the expected value" <| \_ ->
                    Expect.equal "hey" val
            ]
```

You can also include arrays of non-effectful tests with functions from the core test package
like [concat](https://packages.gren-lang.org/package/gren-lang/test/version/latest/module/Test#concat)
and [describe](https://packages.gren-lang.org/package/gren-lang/test/version/latest/module/Test#describe):


```elm
import Expect
import Test exposing (describe, test)
import Test.Runner.Effectful exposing (run, await)

main = 
    run <|
        await (Task.succeed "hello") "my task" <| \resolved ->
            describe "tests for my task"
                [ test "resolves to hello" <| \_ ->
                    Expect.equal "hello" resolved
                , test "is not goodbye" <| \_ ->
                    Expect.notEqual "goodbye" resolved
                ]
```

### Node Environment and Subsystems

If your tasks need access to [Node.Environment](https://packages.gren-lang.org/package/gren-lang/node/version/latest/module/Node#Environment)
or [subsystem permissions](https://packages.gren-lang.org/package/gren-lang/node/version/latest/module/Init)
you can use [init](https://packages.gren-lang.org/package/blaix/gren-effectful-tests-node/version/latest/module/Test.Runner.Effectful#init)
and [thenRun](https://packages.gren-lang.org/package/blaix/gren-effectful-tests-node/version/latest/module/Test.Runner.Effectful#thenRun):

```elm
import Bytes
import Expect
import FileSystem
import Test exposing (test)
import Test.Runner.Effectful exposing (init, thenRun, join, await)


main = 
    init <| \env ->
    
        -- Initialize subsystems here:
        Init.await FileSystem.initialize <| \fsPerm->
        Init.await ChildProcess.initialize <| \processPerm ->
        
            -- Then run your test suite like normal here:
            thenRun env <|
                join
                    [ await (readTestFile fsPerm) "reading test.txt" <| \contents ->
                        test "resolves to contents of file" <| \_ ->
                            Expect.equal "some text\n" content
                    , await (catTestFile processPerm) "cat test.txt" <| \contents ->
                        test "also resolves to contents of file" <| \_ ->
                            Expect.equal "some text\n" content
                    ]


readTestFile : FileSystem.Permission -> Task FileSystem.Error (Maybe String)
readTestFile permission =
    "./test.txt"
        |> Path.fromPosixString
        |> FileSystem.readFile permission
        |> Task.map Bytes.toString


catTestFile : ChildProcess.Permission -> Task ChildProcess.FailedRun ChildProcess.SuccessfulRun
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
