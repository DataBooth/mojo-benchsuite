default:
    @just --list

pixi-tasks:
    @pixi task list

run task:
    pixi run {{task}}

test:
    pixi run test

example:
    pixi run run-example

example-complex:
    pixi run run-example-complex

example-startup:
    pixi run run-example-startup

example-gpu:
    pixi run run-example-gpu

bench:
    pixi run bench-all
