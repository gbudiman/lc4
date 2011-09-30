grammar MicroParser;
@rulecatch {
	catch (RecognitionException re) {
		System.out.println("Not Accepted\n");
		System.exit(1);	
	}
}
@header {
	import java.util.Vector;
	import java.util.LinkedList;
	import java.util.Iterator;
	import java.util.Collections;
	import java.util.ArrayList;
}
@members {
	private List<String> errors = new LinkedList<String>();
	public void displayRecognitionError(String[] tokenNames, RecognitionException e) {
		String hdr = getErrorHeader(e);
		String msg = getErrorMessage(e, tokenNames);
		errors.add(hdr + " " + msg);
	}
	public List<String> getErrors() {
		return errors;
	}
	public int getErrorCount() {
		return errors.size();
	}

	public List<msTable> masterTable = new Vector<msTable>();
	public List<mSymbol> symbolTable = new Vector<mSymbol>();
	public msTable tms = new msTable("__global");
}
/* Program */
program 	: 'PROGRAM' id 'BEGIN' pgm_body 'END'
{
	/*Iterator it = symbolTable.iterator();
	while (it.hasNext()) {
		mSymbol element = (mSymbol) it.next();
		if ((element.getType()).equals("info")) {
			System.out.println(element.getName());
		}
		else {
			System.out.print("name: " + element.getName());
			System.out.print(" type " + element.getType());
			if ((element.getValue()).length() != 0) {
				System.out.println(" value: " + element.getValue());
			}
			else {
			System.out.println();
			}
		}
	}*/
	//System.out.println("Global");
	tms.attachTable(symbolTable);
	masterTable.add(tms);

	Iterator mti = masterTable.iterator();
	while (mti.hasNext()) {
		msTable cmte = (msTable) mti.next();
		if (cmte.scope.equals("__global")) {
			System.out.println("Printing Global Symbol Table");
		}
		else {
			System.out.println("Printing Symbol Table for " + cmte.scope);
		}
		Iterator esti = cmte.symbolTable.iterator();

		while (esti.hasNext()) {
			mSymbol ese = (mSymbol) esti.next();
			System.out.print("name: " + ese.getName());
			System.out.print(" type " + ese.getType());
			if (ese.getValue() != "") {
				System.out.print(" value: " + ese.getValue());
			}
			System.out.println();
		}
		System.out.println();
	}

};
id		: IDENTIFIER;
pgm_body	: decl func_declarations;
decl 		: (string_decl | var_decl)*;
/* Global String Declaration */
//string_decl_list: (string_decl string_decl_tail)?;
string_decl	: 'STRING' id ':=' str ';'
{
	//System.out.println("string_decl returns " + $id.text);
	symbolTable.add(new mSymbol($id.text, "STRING", $str.text));
};
str		: STRINGLITERAL;
string_decl_tail: string_decl string_decl_tail?;
/* Variable Declaration */
//var_decl_list	: var_decl var_decl_tail?;
var_decl	: var_type id_list ';' 
{
	/*List<mSymbol> reverseTable = new Vector<mSymbol>();
	for (String id : $id_list.stringList) {
		reverseTable.add(new mSymbol(id, $var_type.text));
	}
	Collections.reverse(reverseTable);
	Iterator its = reverseTable.iterator();
	while (its.hasNext()) {
		symbolTable.add((mSymbol) its.next());
	}*/
	//Iterator sti = $id_list.stringList.iterator();
	/*while (sti.hasNext()) {
		String init = (String) sti.next();
		//System.out.println("Popped: " + init);
		symbolTable.add(new mSymbol(init, $var_type.text));
	}*/
	while (!$id_list.stringList.empty()) {
		String t = $id_list.stringList.pop();
		//System.out.println("popped: " + t );
		symbolTable.add(new mSymbol(t, $var_type.text));
	}
	//System.out.println("all popped");
};
var_type	: 'FLOAT' | 'INT';
any_type	: var_type | 'VOID';
id_list	returns [ Stack<String> stringList ]
		: id id_tail 
{
	$stringList = $id_tail.stringList;
	$stringList.push($id.text);
	//System.out.println("id_list returns " + $id.text);
};
id_tail returns [ Stack<String> stringList ]
	 	: ',' id tailLambda = id_tail 
{
	$stringList = $tailLambda.stringList;
	$stringList.push($id.text);
	//System.out.println("id_tail returns " + $id.text);
}
		| 
{
	$stringList = new Stack<String>();
	//System.out.println("id_tail returns null");
};
var_decl_tail	: var_decl var_decl_tail?;
/* Function Parameter List */
param_decl_list : param_decl param_decl_tail;
param_decl	: var_type id;
param_decl_tail	: ',' param_decl param_decl_tail | ;
/* Function Delcarations */
func_declarations: (func_decl func_decl_tail)?;
func_decl	: 'FUNCTION' any_type id 
{
	Iterator fti = symbolTable.iterator();
	while (fti.hasNext()) {
		mSymbol init = (mSymbol) fti.next();
		//System.out.println("before exiting, has " + init.getName());
	}
	//System.out.println("Function " + $id.text);
	tms.attachTable(symbolTable);
	masterTable.add(tms);
	tms = new msTable($id.text);
	symbolTable = new Vector<mSymbol>();
}
		'(' param_decl_list? ')' 'BEGIN' func_body 'END' ;
func_decl_tail	: func_decl*;
func_body	: decl stmt_list;
/* Statement List */
stmt_list	: stmt stmt_tail | ;
stmt_tail	: stmt stmt_tail | ;
stmt		: assign_stmt | read_stmt | write_stmt | return_stmt | if_stmt | do_stmt;
/* Basic Statement */
assign_stmt	: assign_expr ';';
assign_expr	: id ':=' expr;
read_stmt	: 'READ' '(' id_list ')' ';';
write_stmt	: 'WRITE' '(' id_list ')' ';';
return_stmt	: 'RETURN' expr ';';
/* Expressions */
expr		: factor expr_tail;
expr_tail	: addop factor expr_tail | ;
factor		: postfix_expr factor_tail;
factor_tail	: mulop postfix_expr factor_tail | ;
postfix_expr	: primary | call_expr;
call_expr	: id '(' expr_list? ')';
expr_list	: expr expr_list_tail;
expr_list_tail 	: ',' expr expr_list_tail |;
primary		: '(' expr ')' | id | INTLITERAL | FLOATLITERAL;
addop		: '+' | '-';
mulop		: '*' | '/';
/* Comples Statemens and Condition */
if_stmt		: 'IF' '(' cond ')' 'THEN' stmt_list else_part 'ENDIF';
else_part	: ('ELSE' stmt_list)*;
cond		: expr compop expr;
compop		: '<' | '>' | '=' | '!=';
do_stmt		: 'DO' stmt_list 'WHILE' '(' cond ')' ';';

fragment DIGIT          : '0'..'9';
fragment LETTER         : 'A'..'Z'|'a'..'z';
fragment ALPHANUMERIC   : '0'..'9'|'A'..'Z'|'a'..'z';

KEYWORD         : 'PROGRAM' 
                | 'BEGIN' 
                | 'END' 
                | 'PROTO' 
                | 'FUNCTION' 
                | 'READ' 
                | 'WRITE' 
                | 'IF' 
                | 'THEN'
                | 'ELSE'
                | 'ENDIF'
                | 'RETURN'
		| 'CASE'
		| 'ENDCASE'
		| 'BREAK'
		| 'DEFAULT'
		| 'DO' 
		| 'WHILE' 
                | 'FLOAT'
                | 'INT' 
                | 'VOID'
                | 'STRING';
/*OPERATOR        : ':='
                | '+'
                | '-'
                | '*'
                | '/'
                | '='
		| '!='
                | '<'
                | '>'
                | '('
                | ')'
                | ';'
                | ',';*/
INTLITERAL      : (DIGIT)+;
FLOATLITERAL    : (DIGIT)*('.'(DIGIT)+);
STRINGLITERAL   : ('"'(~('\r'|'\n'|'"'))*'"');
WHITESPACE      : ('\n'|'\r'|'\t'|' ')+
                {skip();};
COMMENT         : '--'
                (~('\n'|'\r'))*
                ('\n'|'\r'('\n')?)?
                {skip();};
IDENTIFIER      : (LETTER)(ALPHANUMERIC)*;
