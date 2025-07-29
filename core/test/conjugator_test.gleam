import birdie
import conjugator as c
import gleeunit

pub fn main() {
  gleeunit.main()
}

pub fn test_test() {
  let testinput =
    c.Context(
      pronoun: c.je,
      verblookup: "manger",
      verb: c.emptyverb,
      tense: c.Present,
      is_reflexive: False,
      is_negated: False,
    )
  c.conjugate(testinput)
  |> birdie.snap(title: "this is a test test")
}
