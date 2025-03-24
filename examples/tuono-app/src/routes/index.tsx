import type { JSX } from 'react'
import type { TuonoRouteProps } from 'tuono'
import { StateNavHelper } from './StateNavHelper';

interface IndexProps {
  subtitle: string
}

export default function IndexPage(props: TuonoRouteProps<IndexProps>): JSX.Element {
  const {
    isLoading,
  } = props;

  if (isLoading) {
    return <h1>Loading...</h1>
  }

  return (
    <StateNavHelper
      props={props}
      routeName="index"
      title="Index"
    />
  );
}
