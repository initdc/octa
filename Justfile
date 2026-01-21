default:
  just --list --unsorted --justfile {{justfile()}}

sample:
  shards run -- lex spec/octa_spec.cr

lex FILE:
  shards run -- lex {{ FILE }}

parse FILE:
  shards run -- parse {{ FILE }}
