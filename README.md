# ESA (Elixir Static Analysis)

This is:

- First and foremost, a learning project.
- Second, a hopefully useful tool for statically analyzing Elixir source code.
  - Parsing, `@doc`/`@spec` checking, maybe type checking???
- Complete divergence from tools like [credo](https://github.com/rrrene/credo) and [dialyxer](https://github.com/jeremyjh/dialyxir).

## Run

[Install Elixir](https://elixir-lang.org/install.html)

```bash
# get repo
git clone https://github.com/MainShayne233/esa

# enter it
cd esa

# get deps
mix deps.get

# run program
iex -S mix
iex(1)> ESA.Parse.parse_file("path/to_file.exs")

# run tests
mix test
```
