// IMPORTS ---------------------------------------------------------------------
import conjugator as c
import gleam/bool
import gleam/dict
import gleam/list
import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import types as t
import verbs as v

// MAIN ------------------------------------------------------------------------

pub fn main() {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(
    verb: String,
    pronoun: String,
    tense: t.Tense,
    reflexive: Bool,
    negated: Bool,
    output: String,
    debug: Bool,
    description: Bool,
  )
}

fn init(_) -> Model {
  Model(
    verb: "manger",
    pronoun: "je",
    tense: t.Present,
    reflexive: False,
    negated: False,
    output: "hi there!",
    debug: False,
    description: False,
  )
}

// UPDATE ----------------------------------------------------------------------

type Msg {
  UserSelectVerb(String)
  UserSelectPronoun(String)
  UserSelectTense(t.Tense)
  UserCheckedNegated(Bool)
  UserCheckedReflexive(Bool)
  UserClickSubmit
  UserClickDebug
  UserToggleDescription
}

fn update(model: Model, msg: Msg) -> Model {
  case msg {
    UserSelectVerb(verb) -> Model(..model, verb:)
    UserSelectPronoun(pronoun) -> Model(..model, pronoun:)
    UserSelectTense(tense) -> Model(..model, tense:)
    UserCheckedNegated(boxval) -> Model(..model, negated: boxval)
    UserCheckedReflexive(boxval) -> Model(..model, reflexive: boxval)
    UserClickSubmit -> Model(..model, output: send_to_conjugator(model))
    UserClickDebug -> Model(..model, debug: bool.negate(model.debug))
    UserToggleDescription ->
      Model(..model, description: bool.negate(model.description))
  }
}

fn send_to_conjugator(model: Model) -> String {
  let pronoun = case model.pronoun {
    "je" -> v.je
    "tu" -> v.tu
    "il" -> v.il
    "elle" -> v.elle
    "nous" -> v.nous
    "vous" -> v.vous
    "ils" -> v.ils
    _ -> v.elles
  }
  let context =
    t.Context(
      tense: model.tense,
      verblookup: model.verb,
      verb: c.emptyverb,
      is_negated: model.negated,
      is_reflexive: model.reflexive,
      pronoun:,
    )
  c.conjugate(context)
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  echo "test"
  html.div(
    [
      attribute.class(
        "w-screen h-screen bg-fixed bg-no-repeat bg-cover bg-top gap-6",
      ),
      attribute.style("background-image", "url(priv/static/bg2.jpg)"),
    ],
    [
      html.div(
        [
          attribute.class(
            "relative min-h-screen flex flex-col items-center gap-6 p-6 ",
          ),
        ],
        [
          html.span([], case model.debug {
            True -> [html.text(render_model(model))]
            False -> []
          }),
          html.div(
            [
              attribute.class(
                "flex flex-wrap relative w-fit max-w-3xl items-start w-half gap-6 p-10 rounded radius-20 bg-orange-100 border-2",
              ),
            ],
            //main app contents switches here

            list.append(toggle_description(model), [
              html.div(
                [
                  attribute.class(
                    "absolute bottom-2 right-2 text-blue-500 text-sm",
                  ),
                  event.on_click(UserToggleDescription),
                ],
                [html.text("what is this?")],
              ),
            ]),
          ),
          html.div(
            [
              attribute.class(
                "bg-white border-2 border-black py-2 px-5 rounded radius-20",
              ),
            ],
            [html.text(model.output)],
          ),
          html.div([attribute.class("absolute bottom-0 left-0 right-0 z-0")], [
            html.img([
              event.on_click(UserClickDebug),
              attribute.class(
                "mx-auto max-h-[calc(100vh-400px)] object-contain",
              ),
              attribute.src("priv/static/logocropped.png"),
            ]),
          ]),
        ],
      ),
    ],
  )
}

fn toggle_description(model: Model) {
  case model.description {
    True -> description()
    False -> conjugator_controls(model)
  }
}

fn description() {
  [
    html.div([attribute.class("flex sm:flex-row flex-col gap-4")], [
      html.p([], [
        html.text(
          "This is a learning tool to help practice A1-level French. I made this because I kept working on learning gleam instead of working on learning french. So I figured, hey let's kill two birds with one stone. Fast forward to now and I've made my first ever webapp, and absolutely not taken my DELF exam, so let's call it a mixed success. For whatever it's worth, this is my first-ever webapp. You can see the source code on my github if you want a laugh.",
        ),
      ]),
      html.div(
        [attribute.class("flex flex-col  items-center border-2 px-5 py-2")],
        [
          html.a(
            [
              attribute.class(" underline"),
              attribute.href("https://bsky.app/profile/stunwin.com"),
            ],
            [html.text("bluesky")],
          ),
          html.a(
            [
              attribute.class(" underline"),
              attribute.href("https://github.com/stunwin"),
            ],
            [html.text("github")],
          ),
          html.a(
            [
              attribute.class("text-red-400 underline"),
              attribute.href("http://gleam.run"),
            ],
            [html.text("gleam!")],
          ),
        ],
      ),
    ]),
  ]
}

fn conjugator_controls(model: Model) -> List(Element(Msg)) {
  [
    html.div([attribute.class("flex gap-4")], [
      html.select(
        [
          attribute.class("bg-white p-2"),
          attribute.value(model.pronoun),
          event.on_change(fn(x) { UserSelectPronoun(x) }),
        ],
        dropdown_from_list(v.pronounlist, model.pronoun),
      ),
      // dict.keys(dict.from_list(v.verblist))

      // v.pronounlist
      html.select(
        [
          attribute.class("bg-white p-2"),
          attribute.value(model.verb),
          event.on_change(fn(x) { UserSelectVerb(x) }),
        ],
        dropdown_from_list(dict.keys(dict.from_list(v.verblist)), model.verb),
      ),
    ]),
    html.div([attribute.class("flex gap-8")], [
      html.div([attribute.class("flex flex-col gap-2")], tense_radio(model)),
    ]),
    html.div([attribute.class("flex gap-8")], [
      html.div([attribute.class("flex flex-col gap-2")], [
        negated_checkbox(model),
        reflexive_checkbox(model),
      ]),
    ]),
    html.div([attribute.class("flex gap-8")], [
      html.div([attribute.class("flex flex-col gap-2")], [
        html.button(
          [
            attribute.class(
              "bg-blue-100 hover:bg-blue-200 py-2 px-4 rounded border-r-2 border-b-2 border-black",
            ),
            event.on_click(UserClickSubmit),
          ],
          [html.text("conjugate!")],
        ),
      ]),
    ]),
  ]
}

fn render_model(model: Model) -> String {
  let tense = case model.tense {
    t.Present -> "present"
    t.FuturProche -> "future proche"
    t.PasseCompose -> "passe compose"
  }
  let negated = bool.to_string(model.negated)
  let reflexive = bool.to_string(model.reflexive)
  "debug: " <> model.pronoun <> model.verb <> tense <> negated <> reflexive
}

//[[INPUTS]]

fn negated_checkbox(model: Model) {
  html.label([attribute.class("flex items-center gap-2")], [
    html.input([
      attribute.class("gap-2"),
      attribute.type_("checkbox"),
      attribute.id("negated"),
      attribute.checked(model.negated),
      event.on_check(fn(x) { UserCheckedNegated(x) }),
    ]),
    html.text("negated"),
  ])
}

fn reflexive_checkbox(model: Model) {
  html.label([attribute.class("flex items-center gap-2")], [
    html.input([
      attribute.class("gap-2"),
      attribute.type_("checkbox"),
      attribute.id("reflexive"),
      attribute.checked(model.reflexive),
      event.on_check(fn(x) { UserCheckedReflexive(x) }),
    ]),
    html.text("reflexive"),
  ])
}

fn tense_radio(model: Model) {
  let tenselist = [
    #("Present", t.Present),
    #("Futur Proche", t.FuturProche),
    #("Passe Compose", t.PasseCompose),
  ]
  list.map(tenselist, fn(x) {
    let s = x.0
    let t = x.1
    html.label(
      [attribute.for("radio"), attribute.class("flex items-center gap-2")],
      [
        html.input([
          event.on_input(fn(_i) { UserSelectTense(t) }),
          attribute.type_("radio"),
          attribute.name("tense"),
          attribute.value(s),
          attribute.checked(model.tense == t),
        ]),
        html.text(s),
      ],
    )
  })
}

// dict.keys(dict.from_list(v.verblist))

// v.pronounlist
fn dropdown_from_list(optionlist: List(String), selectedvalue: String) {
  list.map(optionlist, fn(x) {
    case x {
      _ if x == selectedvalue -> html.option([attribute.selected(True)], x)
      _ -> html.option([], x)
    }
  })
}
