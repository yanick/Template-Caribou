package Template::Caribou::Tags::Hive;
# ABSTRACT: tags for Apache Hive's workflow markup language

use strict;
use warnings;

use Method::Signatures;

use Template::Caribou::Tags ':all';

use Sub::Exporter -setup => {
    exports => [qw/ 
        workflow
        action
        fs
        oozie_delete
        pig
        map_reduce
        oozie_fork
        oozie_join
        decision
        move
        oozie_kill
    /],
    groups => { default => ':all' },
};

=head2 workflow $name, start => $start, end => $end, \&inner

    workflow 'demo-wf', 
        start => 'cleanup-node',
        end => 'end',
        sub {

        action 'cleanup-node', ...;
    };

=cut

sub workflow(@) {
    my $name = shift;
    my $inner = pop;
    my %arg = @_;

    render_tag( 'workflow', sub {
        attr name => $name;
        for my $t ( grep { $arg{$_} } qw/ start end / ) {
            render_tag( $t, '', sub {
                $_[0]->{to} = $arg{$t};
            });
        }

        $inner->();
    } );

};

=head2 action $name, ok => $node1, error => $node2, $inner;

    action 'cleanup-node',
        ok => 'fork-node',
        error => 'fail',
        sub {
            fs { oozie_delete '/output-data/demo'; }
    };

=cut

sub action(@) {
    my $name = shift;
    my $inner = pop;
    my %arg = @_;

    render_tag( 'action', sub {
        attr name => $name;
        for my $t ( grep { $arg{$_} } qw/ ok error / ) {
            render_tag( $t, '', sub {
                $_[0]->{to} = $arg{$t};
            });
        }

        $inner->();
    } );

};

=head2 fs \&inner

    fs {
        oozie_delete '${nameNode}/user/${wf:user()}/${examplesRoot}/output-data/demo';
    }

=cut

sub fs(&) {
    my $inner = shift;

    render_tag( 'fs', $inner );
}

=head2 oozie_delete $path 

    oozie_delete '${nameNode}/user/${wf:user()}/${examplesRoot}/output-data/demo';

=cut

sub oozie_delete(@) {
    my $path = shift;

    render_tag( 'delete', '', sub {
        $_[0]->{path} = $path;
    });
}

=head2 oozie_fork $name, @nodes

    oozie_fork 'fork-node', qw/
        pig-node
        streaming-node
    /;

=cut

sub oozie_fork(@) {
    my( $name, @nodes ) = @_;
    render_tag( 'fork', sub {
        attr name => $name;
        for my $n ( @nodes ) {
            render_tag( 'path', sub {
                attr start => $n,
            });
        }
    });
}

=head2 pig %args

        pig 
            'job-tracker' => '${JobTracker}',
            'name-node' => '${nameNode}',
            prepare => sub {
                oozie_delete '${nameNode}/user/${wf:user()}/${examplesRoot}/output-data/demo/pig-node';
            },
            configuration => {
                'mapred.job.queue.name' => '${queueName}',
                'mapred.map.output.compress' => 'false',
            },
            script => 'id.pig',
            params => [
            'INPUT=/user/${wf:user()}/${examplesRoot}/input-data/text',
            'OUTPUT=/user/${wf:user()}/${examplesRoot}/output-data/demo/pig-node'
            ];

=cut

sub pig(@) {
    my %arg = @_;
    render_tag( 'pig', sub {
            for my $n ( grep { $arg{$_} } qw/ job-tracker name-node / ) {
                render_tag( $n, $arg{$n} );
            }
            render_tag( 'prepare', $arg{prepare} ) if $arg{prepare};
            if( $arg{configuration} ) {
                render_tag( 'configuration', sub {
                        while( my( $k, $v ) = each %{ $arg{configuration} } ) {
                            render_tag( 'property', sub {
                                    render_tag( 'name' => $k );
                                    render_tag( 'value' => $v );
                                }
                            );
                        }
                } );
            }

            render_tag( 'script' => $arg{'script'} );

            if ( my $params = $arg{params} ) {
                for my $p ( @$params ) {
                    render_tag( 'param' => $p );
                }
            }



    });
}

=head2 map_reduce %args 

        map_reduce 
            job_tracker => '${JobTracker}',
            name_node => '${nameNode}',
            prepare => sub {
                delete => '${nameNode}/user/${wf:user()}/${examplesRoot}/output-data/demo/streaming-node'
            },
            streaming => {
                mapper => '/bin/cat',
                reducer => '/usr/bin/wc',
            },
            configuration => {
                'mapred.job.queue.name' => '${queueName}',
                'mapred.input.dir' => '/user/${wf:user()}/${examplesRoot}/input-data/text',
                'mapred.output.dir' => '/user/${wf:user()}/${examplesRoot}/output-data/demo/streaming-node'
            },
        ;

=cut

sub map_reduce(@) {
    my %arg = @_;
    render_tag( 'map-reduce', sub {
            for my $n ( grep { $arg{$_} } qw/ job-tracker name-node / ) {
                render_tag( $n, $arg{$n} );
            }
            render_tag( 'prepare', $arg{prepare} ) if $arg{prepare};
            if( $arg{configuration} ) {
                render_tag( 'configuration', sub {
                        while( my( $k, $v ) = each %{ $arg{configuration} } ) {
                            render_tag( 'property', sub {
                                    render_tag( 'name' => $k );
                                    render_tag( 'value' => $v );
                                }
                            );
                        }
                } );
            }

            if ( my $s = $arg{streaming} ) {
                render_tag( 'streaming', sub {
                    for my $inner ( qw/ mapper reducer / ) {
                        my $v = $s->{$inner} or next;
                        render_tag( $inner => $v );
                    }
                });
            }


            if ( my $params = $arg{params} ) {
                for my $p ( @$params ) {
                    render_tag( 'param' => $p );
                }
            }



    });
}

=head2 oozie_join $name, $next_node

    oozie_join 'join-node' => 'mr-node';

=cut

sub oozie_join(@) {
    my ( $name, $to ) = @_;
    render_tag( 'join', sub {
        attr name => $name , to => $to;
    });
}

=head2 decision $name, $default, %branches

    decision 'decision-node', 'end', 
        'hdfs-node' => q[${fs:exists('/examplesRoot/)== "true"}];

=cut

sub decision(@) {
    my ( $name, $default, @branches ) = @_;
    render_tag( 'decision', sub {
            attr name => $name;
            render_tag( 'switch', sub {
                while( my( $node, $cond ) = splice @branches, 0, 2 ) {
                    render_tag( 'case', sub {
                        attr to => $node; return $cond;
                    });
                }
                render_tag( 'default' => $default );
            });
    } );
}

=head2 move $src, $target

        move '/mr-node' => '/final-data';
=cut

sub move(@) {
    my( $src, $target ) = @_;
    render_tag( 'move', sub { attr source => $src, target => $target } );
}

=head2 oozie_kill $name, $msg

        oozie_kill 'fail' => <<'URGH';
    Demo workflow failed, error message[${wf:errorMessage(wf:lastErrorNode())}]
    URGH

=cut

sub oozie_kill(@) {
    my( $name, $msg ) = @_;

    render_tag( 'kill', sub {
        attr name => $name;
        render_tag( 'message' => sub { $msg } );
    });

}

1;
