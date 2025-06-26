import types as t

pub const infinitive = t.Je("", "", t.M)

pub const je = t.Je("je", "me", t.M)

pub const tu = t.Tu("tu", "te", t.M)

pub const il = t.Il("il", "se", t.M)

pub const elle = t.Elle("elle", "se", t.F)

pub const nous = t.Nous("nous", "nous", t.M)

pub const vous = t.Vous("vous", "vous", t.M)

pub const ils = t.Ils("ils", "se", t.M)

pub const elles = t.Elles("elles", "se", t.F)

pub const conjugations = [
  t.ConjugationPattern(
    ending: t.Er,
    tense: t.Present,
    suffixes: [
      #(je, "e"),
      #(tu, "es"),
      #(il, "e"),
      #(nous, "ons"),
      #(vous, "ez"),
      #(ils, "ent"),
    ],
  ),
  t.ConjugationPattern(
    ending: t.Ir,
    tense: t.Present,
    suffixes: [
      #(je, "is"),
      #(tu, "is"),
      #(il, "it"),
      #(nous, "issons"),
      #(vous, "issez"),
      #(ils, "issent"),
    ],
  ),
  t.ConjugationPattern(
    ending: t.Re,
    tense: t.Present,
    suffixes: [
      #(je, "s"),
      #(tu, "s"),
      #(il, ""),
      #(nous, "ons"),
      #(vous, "ez"),
      #(ils, "ent"),
    ],
  ),
  t.ConjugationPattern(
    ending: t.Irregular,
    tense: t.Present,
    suffixes: [
      #(je, "vais"),
      #(tu, "vas"),
      #(il, "va"),
      #(nous, "allons"),
      #(vous, "allez"),
      #(ils, "vont"),
      #(infinitive, "aller"),
    ],
  ),
]

pub const sentences = [
  t.SentenceOrder(
    tense: t.Present,
    is_negated: False,
    is_reflexive: False,
    grammar_units: [t.Pronoun, t.MainVerb(t.Conjugated)],
  ),
  t.SentenceOrder(
    tense: t.Present,
    is_negated: True,
    is_reflexive: False,
    grammar_units: [t.Pronoun, t.MainVerb(t.Conjugated)],
  ),
  t.SentenceOrder(
    tense: t.Present,
    is_negated: True,
    is_reflexive: True,
    grammar_units: [
      t.Pronoun,
      t.Ne,
      t.ReflexivePronoun,
      t.MainVerb(t.Conjugated),
      t.Pas,
    ],
  ),
  t.SentenceOrder(
    tense: t.Present,
    is_negated: False,
    is_reflexive: True,
    grammar_units: [t.Pronoun, t.ReflexivePronoun, t.MainVerb(t.Conjugated)],
  ),
  t.SentenceOrder(
    tense: t.FuturProche,
    is_negated: False,
    is_reflexive: False,
    grammar_units: [
      t.Pronoun,
      t.AuxiliaryVerb(t.Verb("aller", t.Irregular)),
      t.MainVerb(t.Infinitive),
    ],
  ),
]
