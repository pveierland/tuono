use serde::{Deserialize, Serialize};
use reqwest::Client;
use tuono_lib::{Props, Request, Response};

const POKEMON_API: &str = "https://pokeapi.co/api/v2/pokemon";

#[derive(Debug, Serialize, Deserialize)]
struct Pokemon {
    name: String,
    id: u16,
    weight: u16,
    height: u16,
}

#[tuono_lib::handler]
async fn get_pokemon(req: Request, fetch: Client) -> Response {
    let pokemon = req.params.get("pokemon").unwrap();

    return match fetch.get(format!("{POKEMON_API}/{pokemon}")).send().await {
        Ok(res) => {
            let data = res.json::<Pokemon>().await.unwrap();
            Response::Props(Props::new(data))
        }
        Err(_err) => Response::Props(Props::new("{}"))
    };
}
