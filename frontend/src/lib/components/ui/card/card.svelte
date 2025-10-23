<script lang="ts">
	import { cn } from "$lib/utils";
	import { cardBaseSchema, type HTMLDivAttributes } from "../helpers";

	type Props = HTMLDivAttributes;

	const props = cardBaseSchema.parse($$restProps) as Props;
</script>

<div class={cn("rounded-lg border bg-card text-card-foreground shadow-sm", props.class ?? "")} {...props}>
	<slot />
</div>