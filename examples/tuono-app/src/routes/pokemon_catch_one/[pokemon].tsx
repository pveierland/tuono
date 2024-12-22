import type { ReactNode } from "react";
import { Link, type TuonoProps } from "tuono";

const LoadingView = () => {
	return <>Loading...</>;
};

export default function TestRoute({
	data,
}: TuonoProps): ReactNode {
	if (data != null) {
		return (
			<>
				<Link href="/pokemon_catch_one/blastoise">blastoise</Link>
				<Link href="/pokemon_catch_one/charmander">charmander</Link>
                <>{data.name}</>
			</>
		);
	} else {
		return <LoadingView />;
	}
}

