import types as t

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
]
