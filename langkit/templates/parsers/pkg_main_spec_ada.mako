## vim: filetype=makoada

with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;

with Interfaces; use Interfaces;

with Langkit_Support.Diagnostics;        use Langkit_Support.Diagnostics;
with Langkit_Support.Token_Data_Handler; use Langkit_Support.Token_Data_Handler;

--  This package provides types and primitives to parse buffers and files and
--  get AST out of them.
--
--  TODO??? For now, consider that this package is not part of the public API.
--  Please use the Analysis package to parse source files.

package ${_self.ada_api_settings.lib_name}.AST.Types.Parsers is

   type Fail_Info is record
      Pos               : Integer := -1;
      Expected_Token_Id : Unsigned_16;
      Found_Token_Id    : Unsigned_16;
   end record;

   type Parser_Type is record
      Current_Pos : Integer := 0;
      Last_Fail   : Fail_Info;
      Diagnostics : Diagnostics_Vectors.Vector;
      TDH         : Token_Data_Handler_Access;
      Mem_Pool    : Bump_Ptr_Pool;
   end record;

   function Create_From_File
     (Filename, Charset : String;
      TDH               : Token_Data_Handler_Access;
      With_Trivia       : Boolean := False) return Parser_type;
   --  Create a parser to parse the source in Filename, decoding it using
   --  Charset. The resulting tokens (and trivia if With_Trivia) are stored
   --  into TDH.
   --
   --  This can raise Lexer.Unknown_Charset or Lexer.Invalid_Input exceptions
   --  if the lexer has trouble decoding the input.

   function Create_From_Buffer
     (Buffer, Charset : String;
      TDH             : Token_Data_Handler_Access;
      With_Trivia     : Boolean := False) return Parser_type;
   --  Create a parser to parse the source in Buffer, decoding it using
   --  Charset. The resulting tokens (and trivia if With_Trivia) are stored
   --  into TDH.
   --
   --  This can raise Lexer.Unknown_Charset or Lexer.Invalid_Input exceptions
   --  if the lexer has trouble decoding the input.

   function Parse
     (Parser         : in out Parser_Type;
      Check_Complete : Boolean := True) return ${root_node_type_name}
     with Inline_Always => True;
   --  Do the actual parsing using the main parsing rule.  If Check_Complete,
   --  consider the case when the parser could not consume all the input tokens
   --  as an error.

   ## Generate user wrappers for all parsing rules
   % for rule_name, parser in sorted(_self.rules_to_fn_names.items()):
      function Parse_${parser._name}
        (Parser         : in out Parser_Type;
         Check_Complete : Boolean := True)
         return ${decl_type(parser.get_type())};
      --  Do the actual parsing using the ${rule_name} parsing rule.  If
      --  Check_Complete, consider the case when the parser could not consume
      --  all the input tokens as an error.
   % endfor

   procedure Clean_All_Memos;
   --  TODO??? We want to allow multiple parsers to run at the same time so
   --  memos should be stored in Parser_Type. In the end, this should be turned
   --  into a Parser_Type finalizer.

end ${_self.ada_api_settings.lib_name}.AST.Types.Parsers;
