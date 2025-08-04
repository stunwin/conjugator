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

pub const pronounlist = [
  "je", "tu", "il", "elle", "nous", "vous", "ils", "elles",
]

pub const conjugations = [
  t.ConjugationPattern(
    ending: t.Er,
    tense: t.Present,
    suffixes: [
      #(je, "e"),
      #(tu, "es"),
      #(il, "e"),
      #(elle, "e"),
      #(nous, "ons"),
      #(vous, "ez"),
      #(ils, "ent"),
      #(elles, "ent"),
    ],
  ),
  t.ConjugationPattern(
    ending: t.Ir,
    tense: t.Present,
    suffixes: [
      #(je, "is"),
      #(tu, "is"),
      #(il, "it"),
      #(elle, "it"),
      #(nous, "issons"),
      #(vous, "issez"),
      #(ils, "issent"),
      #(elles, "issent"),
    ],
  ),
  t.ConjugationPattern(
    ending: t.Re,
    tense: t.Present,
    suffixes: [
      #(je, "s"),
      #(tu, "s"),
      #(il, ""),
      #(elle, ""),
      #(nous, "ons"),
      #(vous, "ez"),
      #(ils, "ent"),
      #(elles, "ent"),
    ],
  ),
  t.ConjugationPattern(
    ending: t.Irregular,
    tense: t.Present,
    suffixes: [
      #(je, "vais"),
      #(tu, "vas"),
      #(il, "va"),
      #(elle, "va"),
      #(nous, "allons"),
      #(vous, "allez"),
      #(ils, "vont"),
      #(elles, "vont"),
      #(infinitive, "aller"),
    ],
  ),
  t.ConjugationPattern(
    ending: t.Irregular,
    tense: t.Present,
    suffixes: [
      #(je, "ai"),
      #(tu, "as"),
      #(il, "a"),
      #(elle, "a"),
      #(nous, "avons"),
      #(vous, "avez"),
      #(ils, "ont"),
      #(elles, "ont"),
      #(infinitive, "avoir"),
    ],
  ),
  t.ConjugationPattern(
    ending: t.Irregular,
    tense: t.Present,
    suffixes: [
      #(je, "suis"),
      #(tu, "es"),
      #(il, "est"),
      #(elle, "est"),
      #(nous, "sommes"),
      #(vous, "êtes"),
      #(ils, "sont"),
      #(elles, "sont"),
      #(infinitive, "être"),
    ],
  ),
  t.ConjugationPattern(
    ending: t.Irregular,
    tense: t.Present,
    suffixes: [
      #(je, "viens"),
      #(tu, "viens"),
      #(il, "vient"),
      #(elle, "vient"),
      #(nous, "venons"),
      #(vous, "venez"),
      #(ils, "viennent"),
      #(elles, "viennent"),
      #(infinitive, "venir"),
    ],
  ),
  t.ConjugationPattern(
    ending: t.Irregular,
    tense: t.Present,
    suffixes: [
      #(je, "nais"),
      #(tu, "nais"),
      #(il, "naît"),
      #(elle, "naît"),
      #(nous, "naissons"),
      #(vous, "naissez"),
      #(ils, "naissent"),
      #(elles, "naissent"),
      #(infinitive, "naître"),
    ],
  ),
  t.ConjugationPattern(
    ending: t.Irregular,
    tense: t.Present,
    suffixes: [
      #(je, "meurs"),
      #(tu, "meurs"),
      #(il, "meurt"),
      #(elle, "meurt"),
      #(nous, "mourons"),
      #(vous, "mourez"),
      #(ils, "meurent"),
      #(elles, "meurent"),
      #(infinitive, "mourir"),
    ],
  ),
  t.ConjugationPattern(
    ending: t.Irregular,
    tense: t.Present,
    suffixes: [
      #(je, "deviens"),
      #(tu, "deviens"),
      #(il, "devient"),
      #(elle, "devient"),
      #(nous, "devenons"),
      #(vous, "devenez"),
      #(ils, "deviennent"),
      #(elles, "deviennent"),
      #(infinitive, "devenir"),
    ],
  ),
  t.ConjugationPattern(
    ending: t.Irregular,
    tense: t.Present,
    suffixes: [
      #(je, "reviens"),
      #(tu, "reviens"),
      #(il, "revient"),
      #(elle, "revient"),
      #(nous, "revenons"),
      #(vous, "revenez"),
      #(ils, "reviennent"),
      #(elles, "reviennent"),
      #(infinitive, "revenir"),
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
    grammar_units: [t.Pronoun, t.Ne, t.MainVerb(t.Conjugated), t.Pas],
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
  //futur proche non negated, non reflexive
  t.SentenceOrder(
    tense: t.FuturProche,
    is_negated: False,
    is_reflexive: False,
    grammar_units: [t.Pronoun, t.AuxiliaryVerb, t.MainVerb(t.Infinitive)],
  ),
  //futur proche negated, non reflexive
  t.SentenceOrder(
    tense: t.FuturProche,
    is_negated: True,
    is_reflexive: False,
    grammar_units: [
      t.Pronoun,
      t.Ne,
      t.AuxiliaryVerb,
      t.Pas,
      t.MainVerb(t.Infinitive),
    ],
  ),
  //futur proche negated, reflexive
  t.SentenceOrder(
    tense: t.FuturProche,
    is_negated: True,
    is_reflexive: True,
    grammar_units: [
      t.Pronoun,
      t.Ne,
      t.AuxiliaryVerb,
      t.Pas,
      t.ReflexivePronoun,
      t.MainVerb(t.Infinitive),
    ],
  ),
  //futur proche non-negated, reflexive
  t.SentenceOrder(
    tense: t.FuturProche,
    is_negated: False,
    is_reflexive: True,
    grammar_units: [
      t.Pronoun,
      t.AuxiliaryVerb,
      t.ReflexivePronoun,
      t.MainVerb(t.Infinitive),
    ],
  ),
  //passe compose non negated, non reflexive
  t.SentenceOrder(
    tense: t.PasseCompose,
    is_negated: False,
    is_reflexive: False,
    grammar_units: [t.Pronoun, t.AuxiliaryVerb, t.MainVerb(t.Participle)],
  ),
  //passe compose negated, non reflexive
  t.SentenceOrder(
    tense: t.PasseCompose,
    is_negated: True,
    is_reflexive: False,
    grammar_units: [
      t.Pronoun,
      t.Ne,
      t.AuxiliaryVerb,
      t.Pas,
      t.MainVerb(t.Participle),
    ],
  ),
  //passe compose negated, reflexive
  t.SentenceOrder(
    tense: t.PasseCompose,
    is_negated: True,
    is_reflexive: True,
    grammar_units: [
      t.Pronoun,
      t.Ne,
      t.AuxiliaryVerb,
      t.Pas,
      t.ReflexivePronoun,
      t.MainVerb(t.Participle),
    ],
  ),
  //passe compose non-negated, reflexive
  t.SentenceOrder(
    tense: t.PasseCompose,
    is_negated: False,
    is_reflexive: True,
    grammar_units: [
      t.Pronoun,
      t.AuxiliaryVerb,
      t.ReflexivePronoun,
      t.MainVerb(t.Participle),
    ],
  ),
]

pub const verblist = [
  #("manger", t.Verb("manger", t.Er)),
  #("avoir", t.Verb("avoir", t.Irregular)),
  #("être", t.Verb("être", t.Irregular)),
  #("aller", t.Verb("aller", t.Irregular)),
  #("venir", t.Verb("venir", t.Irregular)),
  #("arriver", t.Verb("arriver", t.Er)),
  #("partir", t.Verb("partir", t.Ir)),
  #("entrer", t.Verb("entrer", t.Er)),
  #("sortir", t.Verb("sortir", t.Ir)),
  #("monter", t.Verb("monter", t.Er)),
  #("descendre", t.Verb("descendre", t.Re)),
  #("naître", t.Verb("naître", t.Irregular)),
  #("mourir", t.Verb("mourir", t.Irregular)),
  #("rester", t.Verb("rester", t.Er)),
  #("retourner", t.Verb("retourner", t.Er)),
  #("tomber", t.Verb("tomber", t.Er)),
  #("passer", t.Verb("passer", t.Er)),
  #("devenir", t.Verb("devenir", t.Irregular)),
  #("revenir", t.Verb("revenir", t.Irregular)),
  #("rentrer", t.Verb("rentrer", t.Er)),
  #("aimer", t.Verb("aimer", t.Er)),
  #("donner", t.Verb("donner", t.Er)),
  #("trouver", t.Verb("trouver", t.Er)),
  #("parler", t.Verb("parler", t.Er)),
  #("demander", t.Verb("demander", t.Er)),
  #("penser", t.Verb("penser", t.Er)),
  #("aider", t.Verb("aider", t.Er)),
  #("jouer", t.Verb("jouer", t.Er)),
  #("regarder", t.Verb("regarder", t.Er)),
  #("travailler", t.Verb("travailler", t.Er)),
  #("finir", t.Verb("finir", t.Ir)),
  #("choisir", t.Verb("choisir", t.Ir)),
  #("réussir", t.Verb("réussir", t.Ir)),
  #("remplir", t.Verb("remplir", t.Ir)),
  #("grandir", t.Verb("grandir", t.Ir)),
  #("maigrir", t.Verb("maigrir", t.Ir)),
  #("rougir", t.Verb("rougir", t.Ir)),
  #("punir", t.Verb("punir", t.Ir)),
  #("réfléchir", t.Verb("réfléchir", t.Ir)),
  #("obéir", t.Verb("obéir", t.Ir)),
  #("vendre", t.Verb("vendre", t.Re)),
  #("attendre", t.Verb("attendre", t.Re)),
  #("perdre", t.Verb("perdre", t.Re)),
  #("répondre", t.Verb("répondre", t.Re)),
  #("entendre", t.Verb("entendre", t.Re)),
  #("descendre", t.Verb("descendre", t.Re)),
  #("fondre", t.Verb("fondre", t.Re)),
  #("confondre", t.Verb("confondre", t.Re)),
  #("rendre", t.Verb("rendre", t.Re)),
  #("dépendre", t.Verb("dépendre", t.Re)),
]

pub const passe_compose_etre_verbs: List(String) = [
  "aller", "venir", "arriver", "partir", "entrer", "sortir", "monter",
  "descendre", "naître", "mourir", "rester", "retourner", "tomber", "passer",
  "devenir", "revenir", "rentrer", "être",
]

pub const non_reflexive_verbs = [
  "avoir", "être", "naître", "mourir", "aller", "venir", "partir", "arriver",
  "revenir", "devenir", "rentrer", "entrer", "sortir", "monter", "descendre",
  "tomber", "rester", "retourner", "passer",
]
