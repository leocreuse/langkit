from langkit.dsl import ASTNode, Bool, T, abstract
from langkit.expressions import ExternalProperty, Property, Self

from utils import emit_and_print_errors


def run(name, abstract_prop, prop=None):
    """
    Emit and print the errors we get for the below grammar with `abstract_prop`
    as a property in AbstractExample and `prop` (if provided) as a property in
    Example.
    """

    print('== {} =='.format(name))

    class FooNode(ASTNode):
        pass

    @abstract
    class AbstractExample(FooNode):
        p = abstract_prop()
        public_p = Property(Self.p, public=True)

    class Example(AbstractExample):
        if prop:
            p = prop()

    emit_and_print_errors(lkt_file='foo.lkt')
    print('')


run('Missing type',
    lambda: ExternalProperty(uses_entity_info=False, uses_envs=False))

run('Invalid abstract',
    lambda: ExternalProperty(abstract=True, type=T.FooNode,
                             uses_entity_info=False, uses_envs=False),
    lambda: Property(Self))

run('Invalid memoized',
    lambda: ExternalProperty(memoized=True, type=Bool,
                             uses_entity_info=False, uses_envs=False))

run('Missing uses_entity_info=...',
    lambda: ExternalProperty(memoized=True, type=Bool, uses_envs=False))
run('Missing uses_envs=...',
    lambda: ExternalProperty(memoized=True, type=Bool, uses_entity_info=False))

print('Done')
