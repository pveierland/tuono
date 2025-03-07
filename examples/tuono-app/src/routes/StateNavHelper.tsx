import { useEffect, useState, type JSX } from 'react'
import { Link } from 'tuono'
import { isEqual } from 'lodash';

export const StateNavHelper = ({
  props,
  title,
}: {
  props: any,
  title: string,
}): JSX.Element => {
  const [propsStates, setPropsStates] = useState<any[]>([]);

  useEffect(
    () => {
      if (propsStates.length === 0 || !isEqual(propsStates[-1], props)) {
      setPropsStates(value => [...value, props]);
      }
    },
    [props]
  );

  if (props?.isLoading) {
    return <h1>Loading...</h1>
  }

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem'}}>
      <h1>{title}</h1>
      <Link href="/">Index</Link>
      <Link href="/pokemon_catch_none/blastoise">Catch None: Blastoise</Link>
      <Link href="/pokemon_catch_none/charmander">Catch None: Charmander</Link>
      <Link href="/pokemon_catch_one/blastoise">Catch One: Blastoise</Link>
      <Link href="/pokemon_catch_one/charmander">Catch One: Charmander</Link>
      <Link href="/pokemon_catch_all/blastoise">Catch All: Blastoise</Link>
      <Link href="/pokemon_catch_all/charmander">Catch All: Charmander</Link>
      <h2>States</h2>
      {
        propsStates.map((state, index) => (<div key={index}>{JSON.stringify(state)}</div>))
      }
    </div>
  );
}
