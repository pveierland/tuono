import { type JSX } from 'react'
import { type TuonoRouteProps } from "tuono";
import { StateNavHelper } from "../StateNavHelper";

export default function TestRoute(props: TuonoRouteProps<any>): JSX.Element {
  return (
    <StateNavHelper
      props={props}
      routeName="pokemon_catch_one"
      title={`Catch One: ${props?.data?.name}`}
    />
  );
}
