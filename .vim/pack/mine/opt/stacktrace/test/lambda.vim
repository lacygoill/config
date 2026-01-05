vim9script

def Func()
    timer_start(0, (_) => execute('invalid'))
enddef
Func()

[0]->mapnew((_, v) => {
    eval 1 + 0
    eval [][0]
    eval 3 + 0
})

[[]]->map((_, v) =>
    []
    +
    [[][0]]
    +
    []
)

def Func()
    [0]->mapnew((_, v) => {
        eval 1 + 0
        eval [][0]
        eval 3 + 0
    })
enddef
Func()

def Func()
    [[]]->map((_, v) =>
        []
        +
        [[][0]]
        +
        []
    )
enddef
Func()

def A()
    eval 1 + 0
    eval [][0]
    eval 3 + 0
enddef
A()

def A()
    def B()
        eval 1 + 0
        eval [][0]
        eval 3 + 0
    enddef
    B()
enddef
A()

def A()
    def B()
        def C()
            eval 1 + 0
            eval [][0]
            eval 3 + 0
        enddef
        C()
    enddef
    B()
enddef
A()

# TODO: Add the same tests but with `1 / 0` instead of `[][0]`, to get errors at
# compile time.
