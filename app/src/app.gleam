// IMPORTS ---------------------------------------------------------------------
import conjugator as c
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
  Model(verb: String, pronoun: String)
}

fn init(_) -> Model {
  Model(verb: "noverb", pronoun: "nopro")
}

// UPDATE ----------------------------------------------------------------------

type Msg {
  UserSelectVerb(String)
  UserSelectPronoun(String)
}

fn update(model: Model, msg: Msg) -> Model {
  case msg {
    UserSelectVerb(verb) -> Model(..model, verb:)
    UserSelectPronoun(pronoun) -> Model(..model, pronoun:)
  }
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  echo "test"
  html.div([attribute.class("p-32 mx-auto w-full max-w-2xl space-y-4")], [
    html.label([attribute.class("flex gap-2")], [
      html.span([], [html.text(model.pronoun <> " " <> model.verb)]),
      html.p([], [
        html.select(
          [event.on_change(fn(x) { UserSelectPronoun(x) })],
          pronoun_dropdown(),
        ),
        html.select(
          [event.on_change(fn(x) { UserSelectVerb(x) })],
          verb_dropdown(),
        ),
        //TODO: automate this
        html.input([
          event.on_input(fn(x) { UserSelectPronoun(x) }),
          attribute.type_("radio"),
          attribute.name("tense"),
          attribute.value("thingie"),
        ]),
        html.label([attribute.for("radio")], [html.text("thingie")]),
      ]),
    ]),
    html.p([], [html.text("!")]),
  ])
}

fn verb_dropdown() {
  dict.keys(dict.from_list(v.verblist))
  |> list.map(fn(x) { html.option([], x) })
}

fn pronoun_dropdown() {
  list.map(v.pronounlist, fn(x) { html.option([], x) })
}
