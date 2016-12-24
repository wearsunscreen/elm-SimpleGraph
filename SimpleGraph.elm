module SimpleGraph exposing (Graph, findPaths)

import List
import Set


{-| Nodes of a graph must be of type comparable because we define
-}
type alias Edge comparable =
    ( comparable, comparable )


type alias AdjList comparable =
    List ( comparable, List comparable )


type alias Graph comparable =
    ( List comparable, List (Edge comparable) )


{-| add a path to Graph. Edges should be in either the path or the graph but never both
-}
type alias GraphPath comparable =
    ( Graph comparable, List comparable )


{-| Given two nodes a graph, return all acyclic paths in the graph between the two nodes
-}
findPaths : comparable -> comparable -> Graph comparable -> List (List comparable)
findPaths start goal graph =
    List.map Tuple.second <| findPaths_ goal [ ( graph, [ start ] ) ]


{-| Given a goal node and a list of path, recursively search each path
    so we can find all complete paths to the goal
-}
findPaths_ : comparable -> List (GraphPath comparable) -> List (GraphPath comparable)
findPaths_ goal paths =
    case paths of
        [] ->
            []

        p :: ps ->
            if endsAt goal p then
                p :: findPaths_ goal ps
            else
                findPaths_ goal ((extendPath p) ++ ps)


{-| given a path, return a list of all edges connecting to the end of the path
-}
extendPath : GraphPath comparable -> List (GraphPath comparable)
extendPath ( ( gNodes, edges ), pathNodes ) =
    case last pathNodes of
        Nothing ->
            []

        Just x ->
            let
                es =
                    List.filter (\( a, b ) -> (a == x) || (b == x)) edges

                gs =
                    List.repeat (List.length es) ( ( gNodes, edges ), pathNodes )
            in
                List.filter isAcyclic
                    <| List.map2 (\gp e -> addToPath gp e x) gs es


isAcyclic : GraphPath comparable -> Bool
isAcyclic ( g, ns ) =
    List.length ns == Set.size (Set.fromList ns)


{-| given a path, and an edge, construct a GraphPath that adds the edge to the path, and updates the graph to remove the edge
-}
addToPath : GraphPath comparable -> Edge comparable -> comparable -> GraphPath comparable
addToPath ( ( ns, es ), ps ) ( x, y ) end =
    let
        es_ =
            Set.toList <| Set.remove ( x, y ) <| Set.fromList es

        end_ =
            if x == end then
                y
            else
                x
    in
        ( ( ns, es_ ), ps ++ [ end_ ] )


{-| given a value and a path, return if the value matches the last node of the path
-}
endsAt : comparable -> GraphPath comparable -> Bool
endsAt end ( g, ns ) =
    case last ns of
        Nothing ->
            False

        Just x ->
            x == end


last : List a -> Maybe a
last list =
    List.head (List.reverse list)
