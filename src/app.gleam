// IMPORTS ---------------------------------------------------------------------
import conjugator as c
import gleam/bool
import gleam/dict
import gleam/list
import gleam/string
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
  )
}

// UPDATE ----------------------------------------------------------------------

type Msg {
  UserSelectVerb(String)
  UserSelectPronoun(String)
  UserSelectTense(String)
  UserCheckedBox(value: String, bool: Bool)
  UserClickSubmit
  UserClickDebug
}

fn update(model: Model, msg: Msg) -> Model {
  case msg {
    UserSelectVerb(verb) -> Model(..model, verb:)
    UserSelectPronoun(pronoun) -> Model(..model, pronoun:)
    UserSelectTense(tense) -> {
      case tense {
        "Futur Proche" -> Model(..model, tense: t.FuturProche)
        "Passe Compose" -> Model(..model, tense: t.PasseCompose)
        _ -> Model(..model, tense: t.Present)
      }
    }
    UserCheckedBox(value, bool) -> {
      case value {
        "reflexive" -> Model(..model, reflexive: bool)
        "negated" -> Model(..model, negated: bool)
        _ -> model
      }
    }
    UserClickSubmit -> Model(..model, output: send_to_conjugator(model))
    UserClickDebug -> Model(..model, debug: bool.negate(model.debug))
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
      is_reflexive: model.reflexive,
      is_negated: model.negated,
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
                "flex flex-wrap items-start w-half gap-6 p-10 rounded radius-20 bg-orange-100 border-2",
              ),
            ],
            [
              html.div([attribute.class("flex gap-4")], [
                html.select(
                  [
                    attribute.class("bg-white p-2"),
                    event.on_change(fn(x) { UserSelectPronoun(x) }),
                  ],
                  pronoun_dropdown(),
                ),
                html.select(
                  [
                    attribute.class("bg-white p-2"),
                    event.on_change(fn(x) { UserSelectVerb(x) }),
                  ],
                  verb_dropdown(),
                ),
              ]),
              html.div([attribute.class("flex gap-8")], [
                html.div(
                  [attribute.class("flex flex-col gap-2")],
                  tense_radio(),
                ),
              ]),
              html.div([attribute.class("flex gap-8")], [
                html.div(
                  [attribute.class("flex flex-col gap-2")],
                  check_boxes(),
                ),
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
            ],
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
                "mx-auto max-h-[calc(100vh-300px)] object-contain",
              ),
              attribute.src("priv/static/logocropped.png"),
            ]),
          ]),
        ],
      ),
    ],
  )
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

fn check_boxes() {
  let boxlist = ["negated", "reflexive"]

  list.map(boxlist, fn(x) {
    html.label([attribute.class("flex items-center gap-2")], [
      html.input([
        attribute.class("gap-2"),
        attribute.type_("checkbox"),
        event.on_check(fn(b) { UserCheckedBox(value: x, bool: b) }),
      ]),
      html.text(x),
    ])
  })
}

fn tense_radio() {
  let tenselist = ["Present", "Futur Proche", "Passe Compose"]
  list.map(tenselist, fn(x) {
    html.label(
      [attribute.for("radio"), attribute.class("flex items-center gap-2")],
      [
        html.input([
          event.on_input(fn(i) { UserSelectTense(i) }),
          attribute.type_("radio"),
          attribute.name("tense"),
          attribute.value(x),
        ]),
        html.text(x),
      ],
    )
  })
}

fn verb_dropdown() {
  dict.keys(dict.from_list(v.verblist))
  |> list.map(fn(x) { html.option([], x) })
}

fn pronoun_dropdown() {
  list.map(v.pronounlist, fn(x) { html.option([], x) })
}
