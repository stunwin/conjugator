import birdie
import conjugator
import gleeunit
import types as t
import verbs as v

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn first_present_test() {
  let manger = t.Verb(infinitive: "manger", reflexive: False, ending: t.Er)
  conjugator.conjugate(v.je, manger, t.Present)
  |> birdie.snap(title: "first person present non reflexive")
}

pub fn second_present_test() {
  let cuisiner = t.Verb(infinitive: "cuisiner", reflexive: False, ending: t.Er)
  conjugator.conjugate(v.tu, cuisiner, t.Present)
  |> birdie.snap(title: "second person present non reflexive")
}

pub fn first_present_elision_test() {
  let arriver = t.Verb(infinitive: "arriver", reflexive: False, ending: t.Er)
  conjugator.conjugate(v.je, arriver, t.Present)
  |> birdie.snap(title: "first person present non reflexive with elision")
}

pub fn first_plural_present_test() {
  let arriver = t.Verb(infinitive: "arriver", reflexive: False, ending: t.Er)
  conjugator.conjugate(v.nous, arriver, t.Present)
  |> birdie.snap(title: "first person plural present non reflexive no elision ")
}

pub fn third_present_reflexive_test() {
  let coucher = t.Verb(infinitive: "coucher", reflexive: True, ending: t.Er)
  conjugator.conjugate(v.il, coucher, t.Present)
  |> birdie.snap(title: "third person present reflexive")
}
