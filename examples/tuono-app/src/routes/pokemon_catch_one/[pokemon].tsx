import { type JSX } from 'react'
import { type TuonoProps } from "tuono";
import { StateNavHelper } from "../StateNavHelper";

export default function TestRoute(props: TuonoProps<any>): JSX.Element {
  return (
    <StateNavHelper props={props} title={`Catch One: ${props?.data?.name}`} />
  );
}
