require! esprima

flatten = (arr)->
	| typeof! arr is \Array => concat-map flatten,arr
	| otherwise => [arr]

traverse = (func,node)-->
	[func node] ++ for own key,child of node
		switch typeof! child
		| \Array  => map (traverse func), child
		| \Object => traverse func, child

stuff = (f)->
	esprima.parse "(#{f.to-string!})"
	|> traverse (node)->
		if and-list zip-with (is), [
			node.type
			node.callee?.type
			node.callee?.object?.type
		],<[ CallExpression MemberExpression ThisExpression ]> then node.callee.property.name
	|> flatten
	|> filter (?)


console.log (JSON.stringify (stuff ->
	@test!
	@a b:\c
	@b b:\c
	@c b:\c
	@d b:\c
	@e b:\c
	@f b:\c
	@g b:\c
),null,2)