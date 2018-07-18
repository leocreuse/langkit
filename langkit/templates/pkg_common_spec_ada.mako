## vim: filetype=makoada

with Langkit_Support.Slocs;  use Langkit_Support.Slocs;
with Langkit_Support.Symbols;     use Langkit_Support.Symbols;
with Langkit_Support.Text;   use Langkit_Support.Text;

with ${ada_lib_name}.Lexer;       use ${ada_lib_name}.Lexer;
use ${ada_lib_name}.Lexer.Token_Data_Handlers;

with GNATCOLL.GMP.Integers;
with GNATCOLL.Traces;

--  This package provides types and functions used in the whole ${ada_lib_name}
--  package tree.

package ${ada_lib_name}.Common is

   Main_Trace : constant GNATCOLL.Traces.Trace_Handle :=
     GNATCOLL.Traces.Create ("Main_Trace", GNATCOLL.Traces.From_Config);

   Default_Charset : constant String := ${string_repr(ctx.default_charset)};
   --  Default charset to use when creating analysis contexts

   type Grammar_Rule is (
      % for i, name in enumerate(ctx.user_rule_names):
         % if i > 0:
            ,
         % endif
         ${Name.from_lower(name)}_Rule
      % endfor
   );
   ${ada_doc('langkit.grammar_rule_type', 3)}

   Default_Grammar_Rule : constant Grammar_Rule :=
      ${Name.from_lower(ctx.main_rule_name)}_Rule;
   --  Default grammar rule to use when parsing analysis units

   subtype Big_Integer is GNATCOLL.GMP.Integers.Big_Integer;

   ## Output enumerators so that all concrete AST_Node subclasses get their own
   ## kind. Nothing can be an instance of an abstract subclass, so these do not
   ## need their own kind.
   type ${root_node_kind_name} is
     (${', '.join(cls.ada_kind_name
                  for cls in ctx.astnode_types
                  if not cls.abstract)});
   --  AST node concrete types

   for ${root_node_kind_name} use
     (${', '.join('{} => {}'.format(cls.ada_kind_name,
                                    ctx.node_kind_constants[cls])
                  for cls in ctx.astnode_types
                  if not cls.abstract)});

   ## Output subranges to materialize abstract classes as sets of their
   ## concrete subclasses.
   % for cls in ctx.astnode_types:
      <% subclasses = cls.concrete_subclasses %>
      % if subclasses:
         subtype ${cls.ada_kind_range_name} is
            ${root_node_kind_name} range
               ${subclasses[0].ada_kind_name}
               .. ${subclasses[-1].ada_kind_name};
      % endif
   % endfor

   function Is_Token_Node (Kind : ${root_node_kind_name}) return Boolean;
   --  Return whether Kind corresponds to a token node

   function Is_List_Node (Kind : ${root_node_kind_name}) return Boolean;
   --  Return whether Kind corresponds to a list node

   type Visit_Status is (Into, Over, Stop);
   --  Helper type to control the AST node traversal process. See the
   --  ${ada_lib_name}.Analysis.Traverse function.

   type Unit_Kind is (Unit_Specification, Unit_Body);
   ${ada_doc('langkit.unit_kind_type', 3)}

   -----------------------
   -- Lexical utilities --
   -----------------------

   ## TODO PUBLIC API: Put this in ${lib_name}.Parsing. Why do we have two
   ## token types?

   type Token_Reference is record
      TDH : Token_Data_Handler_Access;
      --  Token data handler that owns this token

      Index : Token_Or_Trivia_Index;
      --  Identifier for the trivia or the token this refers to
   end record;
   ${ada_doc('langkit.token_reference_type', 3)}

   No_Token : constant Token_Reference := (null, No_Token_Or_Trivia_Index);

   type Token_Data_Type is record
      Kind : Token_Kind;
      --  See documentation for the Kind accessor

      Is_Trivia : Boolean;
      --  See documentation for the Is_Trivia accessor

      Index : Token_Index;
      --  See documentation for the Index accessor

      Source_Buffer : Text_Cst_Access;
      --  Text for the original source file

      Source_First : Positive;
      Source_Last  : Natural;
      --  Bounds in Source_Buffer for the text corresponding to this token

      Sloc_Range : Source_Location_Range;
      --  See documenation for the Sloc_Range accessor
   end record;

   function "<" (Left, Right : Token_Reference) return Boolean;
   --  Assuming Left and Right belong to the same analysis unit, return whether
   --  Left came before Right in the source file.

   function Next
     (Token          : Token_Reference;
      Exclude_Trivia : Boolean := False) return Token_Reference;
   ${ada_doc('langkit.token_next', 3)}

   function Previous
     (Token          : Token_Reference;
      Exclude_Trivia : Boolean := False) return Token_Reference;
   ${ada_doc('langkit.token_previous', 3)}

   function Data (Token : Token_Reference) return Token_Data_Type;
   --  Return the data associated to T

   function Is_Equivalent (L, R : Token_Reference) return Boolean;
   ${ada_doc('langkit.token_is_equivalent', 3)}

   function Image (Token : Token_Reference) return String;
   --  Debug helper: return a human-readable text to represent a token

   function Text (Token : Token_Reference) return Text_Type;
   --  Return the text of the token as Text_Type

   function Text (Token : Token_Reference) return String;
   --  Return the text of the token as String

   function Text (First, Last : Token_Reference) return Text_Type;
   ${ada_doc('langkit.token_range_text', 3)}

   function Get_Symbol (Token : Token_Reference) return Symbol_Type;
   --  Assuming that Token refers to a token that contains a symbol, return the
   --  corresponding symbol.

   function Kind (Token_Data : Token_Data_Type) return Token_Kind;
   ${ada_doc('langkit.token_kind', 3)}

   function Is_Trivia (Token : Token_Reference) return Boolean;
   ${ada_doc('langkit.token_is_trivia', 3)}

   function Is_Trivia (Token_Data : Token_Data_Type) return Boolean;
   ${ada_doc('langkit.token_is_trivia', 3)}

   function Index (Token : Token_Reference) return Token_Index;
   function Index (Token_Data : Token_Data_Type) return Token_Index;
   ${ada_doc('langkit.token_index', 3)}

   function Sloc_Range
     (Token_Data : Token_Data_Type) return Source_Location_Range;
   --  Source location range for this token. Note that the end bound is
   --  exclusive.

   function Convert
     (TDH      : Token_Data_Handler;
      Token    : Token_Reference;
      Raw_Data : Lexer.Token_Data_Type) return Common.Token_Data_Type;
   --  Turn data from TDH and Raw_Data into a user-ready token data record

   type Child_Or_Trivia is (Child, Trivia);
   --  Discriminator for the Child_Record type

   Property_Error : exception;
   ${ada_doc('langkit.property_error', 3)}

   Invalid_Unit_Name_Error : exception;
   ${ada_doc('langkit.invalid_unit_name_error', 3)}

   function Raw_Data (T : Token_Reference) return Lexer.Token_Data_Type;
   --  Return the raw token data for T

   procedure Raise_Property_Error (Message : String := "");
   --  Raise a Property_Error with the given Message

end ${ada_lib_name}.Common;