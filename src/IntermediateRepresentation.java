class IntermediateRepresentation {

	public IntermediateRepresentation() {
	}

	public String arithmetic(String a, String b, String target, char op, String type) {
		String opcode = "";
		switch (op) {
			case '+': opcode += "ADD"; 	break;
			case '-': opcode += "SUB";	break;
			case '*': opcode += "MULT";	break;
			case '/': opcode += "DIV";	break;
		}

		if (type.equals("INT")) {
			opcode += "I";
		}
		else if (type.equals("FLOAT")) {
			opcode += "F";
		}

		return (opcode + ' ' + a + ' ' + b + ' ' + target);
	}

	public String store(String a, String result, String type) {
		if (type.equals("INT")) {
			return ("STOREI " + a + ' ' + result);
		}
		else if (type.equals("FLOAT")) {
			return ("STOREF " + a + ' ' + result);
		}

		return null;
	}

	public String rw(String result, String action, String type) {
		if (type.equals("INT")) {
			return (action + "I " + result);
		}
		else if (type.equals("FLOAT")) {
			return (action + "F " + result);
		}

		return null;
	}

	public String comparison(String a, String b, String op, String target) {
		String opcode = "";

		if (op.equals(">")) { opcode += "GE"; }
		else if (op.equals("<")) { opcode += "LE"; }
		else if (op.equals("!=")) { opcode += "NE"; }

		return (opcode + ' ' + a + ' ' + b + ' ' + target);
	}

	public String jump(String target) {
		return ("JUMP " + target);
	}

	public String label(String l) {
		return ("LABEL " + l);
	}
}
