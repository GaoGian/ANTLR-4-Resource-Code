/** Derived from http://www.graphviz.org/doc/info/lang.html.
    Comments pulled from spec.

has some ambig on

digraph structs {
    node [shape=plaintext]
    struct1 [label=<<i>foo</i>>];
    struct1 [label=<&epsilon;>];
    struct2 [label=<
<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0">
  <TR><TD PORT="f0">one</TD><TD>two</TD></TR>
</TABLE>>];
    struct3 [label=<
<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="4">
  <TR>
    <TD ROWSPAN="3">hello<BR/>world</TD>
    <TD COLSPAN="3">b</TD>
    <TD ROWSPAN="3">g</TD>
    <TD ROWSPAN="3">h</TD>
  </TR>
  <TR>
    <TD>c</TD><TD PORT="here">d</TD><TD>e</TD>
  </TR>
  <TR>
    <TD COLSPAN="3">f</TD>
  </TR>
</TABLE>>];
    struct1:f1 -> struct2:f0;
    struct1:f2 -> struct3:here;
}
 */
grammar DOT;

graph       :   STRICT? (GRAPH | DIGRAPH) id? '{' stmt_list '}' ;
stmt_list   :   ( stmt ';'? )* ;
stmt        :   node_stmt
            |   edge_stmt
            |   attr_stmt
            |   id '=' id
            |   subgraph 
            ;
attr_stmt   :   (GRAPH | NODE | EDGE) attr_list ;
attr_list   :   ('[' a_list? ']')+ ;
a_list      :   (id ('=' id)? ','?)+ ;
edge_stmt   :   (node_id | subgraph) edgeRHS attr_list? ;
edgeRHS     :   ( edgeop (node_id | subgraph) )+ ;
edgeop      :   '->' | '--' ;
node_stmt   :   node_id attr_list? ;
node_id     :   id port? ;
port        :   ':' id (':' compass_pt)?
            |   ':' compass_pt
            ;
subgraph    :   (SUBGRAPH id?)? '{' stmt_list '}' ;
/** "the allowed compass point values are not keywords, so these strings
 *  can be used elsewhere as ordinary identifiers and, conversely, the
 *  parser will actually accept any identifier.
 *  'n' | 'ne' | 'e' | 'se' | 's' | 'sw' | 'w' | 'nw' | 'c' | '_'"
 *  TJP: later the ID needs to be checked for membership in these
 *  compass points.
 */
compass_pt  :   ID | '_' ;
id          :   ID
            |   STRING
            |   HTML_STRING
            |   NUMBER
            ;

// "The keywords node, edge, graph, digraph, subgraph, and strict are
// case-independent"
STRICT      :   [Ss][Tt][Rr][Ii][Cc][Tt] ;
GRAPH       :   [Gg][Rr][Aa][Pp][Hh] ;
DIGRAPH     :   [Dd][Ii][Gg][Rr][Aa][Pp][Hh] ;
NODE        :   [Nn][Oo][Dd][Ee] ;
EDGE        :   [Ee][Dd][Gg][Ee] ;
SUBGRAPH    :   [Ss][Uu][Bb][Gg][Rr][Aa][Pp][Hh] ;

/** "a numeral [-]?(.[0-9]+ | [0-9]+(.[0-9]*)? )" */
NUMBER      :   '-'? ('.' DIGIT+ | DIGIT+ ('.' DIGIT*)? ) ;
fragment
DIGIT       :   '0'..'9' ;

/** "any double-quoted string ("...") possibly containing escaped quotes" */
STRING      :   '"' ('\\"'|.)*? '"' ;

/** "HTML strings, angle brackets must occur in matched pairs, and
 *  unescaped newlines are allowed."
 */

HTML_STRING :   '<' (TAG|EntityRef|.)* '>' ;
TAG         :   '<' .*? '>' ;
EntityRef   :   '&' LETTER+ ';' ;

/** "Any string of alphabetic ([a-zA-Z\200-\377]) characters, underscores
 *  ('_') or digits ([0-9]), not beginning with a digit"
 */
ID          :   LETTER (LETTER|DIGIT)*;
fragment
LETTER      :   [a-zA-Z\u0080-\u00FF_] ;

COMMENT     :   '/*' .*? '*/' {skip();} ;
LINE_COMMENT:   '//' .*? '\r'? '\n' {skip();} ;
/** "a '#' character is considered a line output from a C preprocessor (e.g.,
 *  # 34 to indicate line 34 ) and discarded"
 */
PREPROC     :   '#' .*? '\n' -> skip ;

WS          :   [ \t\r\n] -> skip ;
