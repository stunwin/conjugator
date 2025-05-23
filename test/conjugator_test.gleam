import birdie
import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/string
import gleeunit
import gleeunit/should
import types as t
import verbs as v

pub fn main() -> Nil {
  let manger = t.Verb(infinitive: "manger", reflexive: False, ending: t.Er)
  let cuisiner = t.Verb(infinitive: "cuisiner", reflexive: False, ending: t.Er)
  let arriver = t.Verb(infinitive: "arriver", reflexive: False, ending: t.Er)
  let coucher = t.Verb(infinitive: "coucher", reflexive: True, ending: t.Er)
  echo conjugate(v.je, manger, t.Present)
  echo conjugate(v.tu, cuisiner, t.Present)
  echo conjugate(v.je, arriver, t.Present)
  echo conjugate(v.nous, arriver, t.Present)
  echo conjugate(v.il, coucher, t.Present)
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn hello_world_test() {
  1
  |> should.equal(1)
}
