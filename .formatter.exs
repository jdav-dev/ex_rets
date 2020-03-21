locals_without_parens = [
  parse_xml: 3,
  root: 3,
  attribute: 2,
  attribute: 3,
  element: 2,
  element: 4,
  text: 1,
  text: 2
]

[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: locals_without_parens,
  export: [locals_without_parens: locals_without_parens]
]
