# Gren Effectful Test Runner

Run [Gren](https://gren-lang.org/) integration tests that depend on the actual results of [tasks](https://gren-lang.org/book/applications/tasks/).

See the full API on [the package site](https://packages.gren-lang.org/package/blaix/gren-effectful-tests-node).

## Example

```elm
module Main exposing (main)

import Task
import Test exposing (describe, test)
import Expect
import Test.Runner.Effectful exposing (Program, await, run)
import Time

main : Program
main = run
    [ await Time.now "test that depends on result of a task" <| \now ->
        describe "nest a full test suite if you want"
            [ test "test that fails" <| \_ ->
                Expect.equal (Time.millisToPosix 0) now
            ]

    , await (Task.fail "oops") "task that fails" <| \_ ->
        test "the suite will fail and this test will never run" <| \_ ->
            Expect.equal True True
    ]
```

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
See the [example above](#Example) or the [example in the repo](/example/src/Main.gren).

Then compile and run your tests:

```
gren make src/Main.gren
node app
```

## Contact

Found a problem? Need some help?
You can [open an issue](https://github.com/blaix/gren-effectful-tests-node/issues),
find me [on mastodon](https://hachyderm.io/@blaix),
or on the [Gren Discord](https://gren-lang.org/community).
