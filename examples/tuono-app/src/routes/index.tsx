import { type JSX } from 'react'
import { type TuonoProps } from 'tuono'
import { StateNavHelper } from './StateNavHelper';

export default function IndexPage(props: TuonoProps<any>): JSX.Element {
  return (
    <StateNavHelper props={props} title="Index" />
  );
}
