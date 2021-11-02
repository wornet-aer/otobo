# --
# OTOBO is a web-based ticketing system for service organisations.
# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# Copyright (C) 2019-2020 Rother OSS GmbH, https://otobo.de/
# --
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

# ---
# OTOBOTicketInvoker
# ---
#package Kernel::Modules::AdminGenericInterfaceInvokerDefault;
package Kernel::Modules::AdminGenericInterfaceInvokerTicket;
# ---

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);
use Kernel::Language qw(Translatable);

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my $WebserviceID = $Kernel::OM->Get('Kernel::System::Web::Request')->GetParam( Param => 'WebserviceID' );
    if ( !IsStringWithData($WebserviceID) ) {
        return $LayoutObject->ErrorScreen(
            Message => Translatable('Need WebserviceID!'),
        );
    }

    $LayoutObject->AddJSData(
        Key   => 'WebserviceID',
        Value => $WebserviceID
    );

    my $WebserviceData = $Kernel::OM->Get('Kernel::System::GenericInterface::Webservice')->WebserviceGet(
        ID => $WebserviceID,
    );

    if ( !IsHashRefWithData($WebserviceData) ) {
        return $LayoutObject->ErrorScreen(
            Message =>
                $LayoutObject->{LanguageObject}->Translate( 'Could not get data for WebserviceID %s', $WebserviceID ),
        );
    }

    if ( $Self->{Subaction} eq 'Add' ) {
        return $Self->_Add(
            %Param,
            WebserviceID   => $WebserviceID,
            WebserviceData => $WebserviceData,
        );
    }
    elsif ( $Self->{Subaction} eq 'AddAction' ) {

        # Challenge token check for write action.
        $LayoutObject->ChallengeTokenCheck();

        return $Self->_AddAction(
            %Param,
            WebserviceID   => $WebserviceID,
            WebserviceData => $WebserviceData,
        );
    }
    elsif ( $Self->{Subaction} eq 'Change' ) {
        return $Self->_Change(
            %Param,
            WebserviceID   => $WebserviceID,
            WebserviceData => $WebserviceData,
        );
    }
    elsif ( $Self->{Subaction} eq 'ChangeAction' ) {

        # Challenge token check for write action.
        $LayoutObject->ChallengeTokenCheck();

        return $Self->_ChangeAction(
            %Param,
            WebserviceID   => $WebserviceID,
            WebserviceData => $WebserviceData,
        );
    }
    elsif ( $Self->{Subaction} eq 'DeleteAction' ) {

        # Challenge token check for write action.
        $LayoutObject->ChallengeTokenCheck();

        return $Self->_DeleteAction(
            %Param,
            WebserviceID   => $WebserviceID,
            WebserviceData => $WebserviceData,
        );
    }
    elsif ( $Self->{Subaction} eq 'AddEvent' ) {

        # Challenge token check for write action.
        $LayoutObject->ChallengeTokenCheck();

        return $Self->_AddEvent(
            %Param,
            WebserviceID   => $WebserviceID,
            WebserviceData => $WebserviceData,
        );
    }
    elsif ( $Self->{Subaction} eq 'DeleteEvent' ) {

        # Challenge token check for write action.
        $LayoutObject->ChallengeTokenCheck();

        return $Self->_DeleteEvent(
            %Param,
            WebserviceID   => $WebserviceID,
            WebserviceData => $WebserviceData,
        );
    }

    return $LayoutObject->ErrorScreen(
        Message => Translatable('Invalid Subaction!'),
    );
}

sub _Add {
    my ( $Self, %Param ) = @_;

    my $GetParam = $Self->_ParamsGet(
        Definition => [
            {
                Name      => 'InvokerType',
                Type      => 'String',
                Mandatory => 1,
                Check     => 'InvokerType',
            },
        ],
    );
    if ( $GetParam->{Error} ) {
        return $Kernel::OM->Get('Kernel::Output::HTML::Layout')->ErrorScreen(
            Message => $GetParam->{Error},
        );
    }

    return $Self->_ShowScreen(
        %Param,
        Mode          => 'Add',
        InvokerConfig => {
            Type => $GetParam->{InvokerType},
        },
    );
}

sub _AddAction {
    my ( $Self, %Param ) = @_;

    my $GetParam = $Self->_ParamsGet(
        Definition => [
            {
                Name      => 'InvokerType',
                Type      => 'String',
                Mandatory => 1,
                Check     => 'InvokerType',
            },
            {
                Name    => 'Invoker',
                Type    => 'String',
                Default => '',
            },
            {
                Name    => 'Description',
                Type    => 'String',
                Default => '',
            },
            {
                Name  => 'MappingInbound',
                Type  => 'String',
                Check => 'MappingType',
            },
            {
                Name  => 'MappingOutbound',
                Type  => 'String',
                Check => 'MappingType',
            },
# ---
# OTOBOTicketInvoker
# ---
            {
                Name    => 'CountLastArticle',
                Type    => 'String',
                Default => '',
            },
            {
                Name    => 'TicketIdToDynamicField',
                Type    => 'String',
                Default => '',
            },
            {
                Name => 'CommunicationChannel',
                Type => 'Array',
            },
            {
                Name    => 'CustomerVisibility',
                Type    => 'String',
                Default => 2,
            },
            {
                Name => 'ArticleSenderType',
                Type => 'Array',
            },
            {
                Name => 'DynamicFieldList',
                Type => 'Array',
            },
            {
                Name => 'RequestDynamicFieldsArticle',
                Type => 'Array',
            },
            {
                Name => 'RequestDynamicFieldsTicket',
                Type => 'Array',
            },
            {
                Name => 'RequestArticleFields',
                Type => 'Array',
            },
            {
                Name => 'RequestTicketFields',
                Type => 'Array',
            },
# ---
        ],
    );

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    if ( $GetParam->{Error} ) {
        return $LayoutObject->ErrorScreen(
            Message => $GetParam->{Error},
        );
    }

    my $WebserviceData = $Param{WebserviceData};
    my %Errors;
    if ( !IsStringWithData( $GetParam->{Invoker} ) ) {
        $Errors{InvokerServerError} = 'ServerError';
    }

    # Invoker with same name already exists.
    elsif ( IsHashRefWithData( $WebserviceData->{Config}->{Requester}->{Invoker}->{ $GetParam->{Invoker} } ) ) {
        $Errors{InvokerServerError} = 'ServerError';
    }
# ---
# OTOBOTicketInvoker
# ---

    # Field for remote ticket id must not be used for writing incoming dynamic field data.
    if ( grep { $_ eq $GetParam->{TicketIdToDynamicField} } @{ $GetParam->{DynamicFieldList} } ) {
        $Errors{TicketIdToDynamicFieldServerError} = 'ServerError';
    }
# ---

    my $InvokerConfig = {
        Description => $GetParam->{Description},
        Type        => $GetParam->{InvokerType},
# ---
# OTOBOTicketInvoker
# ---
        CountLastArticle            => $GetParam->{CountLastArticle},
        TicketIdToDynamicField      => $GetParam->{TicketIdToDynamicField},
        CommunicationChannel        => $GetParam->{CommunicationChannel},
        CustomerVisibility          => $GetParam->{CustomerVisibility},
        ArticleSenderType           => $GetParam->{ArticleSenderType},
        DynamicFieldList            => $GetParam->{DynamicFieldList},
        RequestDynamicFieldsArticle => $GetParam->{RequestDynamicFieldsArticle},
        RequestDynamicFieldsTicket  => $GetParam->{RequestDynamicFieldsTicket},
        RequestArticleFields        => $GetParam->{RequestArticleFields},
        RequestTicketFields         => $GetParam->{RequestTicketFields},
# ---
    };

    # Validation errors.
    if (%Errors) {
        return $Self->_ShowScreen(
            %Param,
            %{$GetParam},
            %Errors,
            Mode          => 'Add',
            InvokerConfig => $InvokerConfig,
        );
    }

    DIRECTION:
    for my $Direction (qw(MappingInbound MappingOutbound)) {
        next DIRECTION if !$GetParam->{$Direction};

        # Mapping added, initialize with empty config.
        $InvokerConfig->{$Direction} = {
            Type => $GetParam->{$Direction},
        };
    }

    $WebserviceData->{Config}->{Requester}->{Invoker}->{ $GetParam->{Invoker} } = $InvokerConfig;

    my $UpdateSuccess = $Kernel::OM->Get('Kernel::System::GenericInterface::Webservice')->WebserviceUpdate(
        %{$WebserviceData},
        UserID => $Self->{UserID},
    );
    if ( !$UpdateSuccess ) {
        return $LayoutObject->ErrorScreen(
            Message => Translatable('Could not update web service'),
        );
    }

    my $RedirectURL =
        'Action='
        . $Self->{Action}
        . ';Subaction=Change;WebserviceID='
        . $Param{WebserviceID}
        . ';Invoker='
        . $LayoutObject->LinkEncode( $GetParam->{Invoker} )
        . ';';

    return $LayoutObject->Redirect(
        OP => $RedirectURL,
    );
}

sub _Change {
    my ( $Self, %Param ) = @_;

    my $GetParam = $Self->_ParamsGet(
        Definition => [
            {
                Name      => 'Invoker',
                Type      => 'String',
                Mandatory => 1,
            },
            {
                Name    => 'EventType',
                Type    => 'String',
                Default => 'Ticket',
            },
        ],
    );

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    if ( $GetParam->{Error} ) {
        return $LayoutObject->ErrorScreen(
            Message => $GetParam->{Error},
        );
    }

    my $WebserviceData = $Param{WebserviceData};
    my $InvokerConfig  = $WebserviceData->{Config}->{Requester}->{Invoker}->{ $GetParam->{Invoker} };
    if ( !IsHashRefWithData($InvokerConfig) ) {
        return $LayoutObject->ErrorScreen(
            Message =>
                $LayoutObject->{LanguageObject}
                ->Translate( 'Could not determine config for invoker %s', $GetParam->{Invoker} ),
        );
    }

    return $Self->_ShowScreen(
        %Param,
        %{$GetParam},
        Mode            => 'Change',
        Invoker         => $GetParam->{Invoker},
        InvokerConfig   => $InvokerConfig,
        MappingInbound  => $InvokerConfig->{MappingInbound}->{Type},
        MappingOutbound => $InvokerConfig->{MappingOutbound}->{Type},
    );
}

sub _ChangeAction {
    my ( $Self, %Param ) = @_;

    my $GetParam = $Self->_ParamsGet(
        Definition => [
            {
                Name      => 'OldInvoker',
                Type      => 'String',
                Mandatory => 1,
            },
            {
                Name    => 'Invoker',
                Type    => 'String',
                Default => '',
            },
            {
                Name    => 'Description',
                Type    => 'String',
                Default => '',
            },
            {
                Name  => 'MappingInbound',
                Type  => 'String',
                Check => 'MappingType',
            },
            {
                Name  => 'MappingOutbound',
                Type  => 'String',
                Check => 'MappingType',
            },
            {
                Name    => 'ContinueAfterSave',
                Type    => 'String',
                Default => '',
            },
            {
                Name    => 'EventType',
                Type    => 'String',
                Default => 'Ticket',
            },
# ---
# OTOBOTicketInvoker
# ---
            {
                Name    => 'CountLastArticle',
                Type    => 'String',
                Default => '',
            },
            {
                Name    => 'TicketIdToDynamicField',
                Type    => 'String',
                Default => '',
            },
            {
                Name => 'CommunicationChannel',
                Type => 'Array',
            },
            {
                Name    => 'CustomerVisibility',
                Type    => 'String',
                Default => 2,
            },
            {
                Name => 'ArticleSenderType',
                Type => 'Array',
            },
            {
                Name => 'DynamicFieldList',
                Type => 'Array',
            },
            {
                Name => 'RequestDynamicFieldsArticle',
                Type => 'Array',
            },
            {
                Name => 'RequestDynamicFieldsTicket',
                Type => 'Array',
            },
            {
                Name => 'RequestArticleFields',
                Type => 'Array',
            },
            {
                Name => 'RequestTicketFields',
                Type => 'Array',
            },
# ---
        ],
    );

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    if ( $GetParam->{Error} ) {
        return $LayoutObject->ErrorScreen(
            Message => $GetParam->{Error},
        );
    }

    my $WebserviceData = $Param{WebserviceData};
    my $InvokerConfig  = delete $WebserviceData->{Config}->{Requester}->{Invoker}->{ $GetParam->{OldInvoker} };
    if ( !IsHashRefWithData($InvokerConfig) ) {
        return $LayoutObject->ErrorScreen(
            Message => $LayoutObject->{LanguageObject}
                ->Translate( 'Could not determine config for invoker %s', $GetParam->{OldInvoker} ),
        );
    }

    my %Errors;
    if ( !IsStringWithData( $GetParam->{Invoker} ) ) {
        $Errors{InvokerServerError} = 'ServerError';
    }

    # Invoker was renamed and new name already exists.
    elsif (
        $GetParam->{OldInvoker} ne $GetParam->{Invoker}
        && IsHashRefWithData( $WebserviceData->{Config}->{Requester}->{Invoker}->{ $GetParam->{Invoker} } )
        )
    {
        $Errors{InvokerServerError} = 'ServerError';
    }
# ---
# OTOBOTicketInvoker
# ---

    # Field for remote ticket id must not be used for writing incoming dynamic field data.
    if ( grep { $_ eq $GetParam->{TicketIdToDynamicField} } @{ $GetParam->{DynamicFieldList} } ) {
        $Errors{TicketIdToDynamicFieldServerError} = 'ServerError';
    }
# ---

    $InvokerConfig->{Description} = $GetParam->{Description};
# ---
# OTOBOTicketInvoker
# ---
    $InvokerConfig->{CountLastArticle}            = $GetParam->{CountLastArticle};
    $InvokerConfig->{TicketIdToDynamicField}      = $GetParam->{TicketIdToDynamicField};
    $InvokerConfig->{CommunicationChannel}        = $GetParam->{CommunicationChannel};
    $InvokerConfig->{CustomerVisibility}          = $GetParam->{CustomerVisibility};
    $InvokerConfig->{ArticleSenderType}           = $GetParam->{ArticleSenderType};
    $InvokerConfig->{DynamicFieldList}            = $GetParam->{DynamicFieldList};
    $InvokerConfig->{RequestDynamicFieldsArticle} = $GetParam->{RequestDynamicFieldsArticle};
    $InvokerConfig->{RequestDynamicFieldsTicket}  = $GetParam->{RequestDynamicFieldsTicket};
    $InvokerConfig->{RequestArticleFields}        = $GetParam->{RequestArticleFields};
    $InvokerConfig->{RequestTicketFields}         = $GetParam->{RequestTicketFields};
# ---

    if (%Errors) {
        return $Self->_ShowScreen(
            %Param,
            %{$GetParam},
            %Errors,
            Mode          => 'Change',
            Invoker       => $GetParam->{OldInvoker},
            InvokerConfig => $InvokerConfig,
            NewInvoker    => $GetParam->{Invoker},
        );
    }

    # If mapping types were not changed, keep the mapping configuration.
    DIRECTION:
    for my $Direction (qw(MappingInbound MappingOutbound)) {

        # No mapping set, make sure it is not present in the configuration.
        if ( !$GetParam->{$Direction} ) {
            delete $InvokerConfig->{$Direction};
            next DIRECTION;
        }

        # Mapping added or changed, initialize with empty config.
        my $OldMapping = $InvokerConfig->{$Direction}->{Type};
        if ( !$OldMapping || ( $OldMapping && $GetParam->{$Direction} ne $OldMapping ) ) {
            $InvokerConfig->{$Direction} = {
                Type => $GetParam->{$Direction},
            };
        }
    }

    # Update invoker config.
    $WebserviceData->{Config}->{Requester}->{Invoker}->{ $GetParam->{Invoker} } = $InvokerConfig;

    # Take care of error handlers with invoker filters if invoker was renamed.
    if (
        $GetParam->{OldInvoker} ne $GetParam->{Invoker}
        && IsHashRefWithData( $WebserviceData->{Config}->{Requester}->{ErrorHandling} )
        )
    {
        my $ErrorHandlingConfig = $WebserviceData->{Config}->{Requester}->{ErrorHandling};

        ERRORHANDLING:
        for my $ErrorHandling ( sort keys %{$ErrorHandlingConfig} ) {
            next ERRORHANDLING if !IsHashRefWithData( $ErrorHandlingConfig->{$ErrorHandling} );

            my $InvokerFilter = $ErrorHandlingConfig->{$ErrorHandling}->{InvokerFilter};
            next ERRORHANDLING if !IsArrayRefWithData($InvokerFilter);

            next ERRORHANDLING if !grep { $_ eq $GetParam->{OldInvoker} } @{$InvokerFilter};

            # Rename invoker in error handling invoker filter to keep consistency.
            my @NewInvokerFilter = map { $_ eq $GetParam->{OldInvoker} ? $GetParam->{Invoker} : $_ } @{$InvokerFilter};
            $ErrorHandlingConfig->{$ErrorHandling}->{InvokerFilter} = \@NewInvokerFilter;
        }

        $WebserviceData->{Config}->{Requester}->{ErrorHandling} = $ErrorHandlingConfig;
    }
# ---
# OTOBOTicketInvoker
# ---

    # Take care of invoker dependent configuration if invoker was renamed.
    if ( $GetParam->{OldInvoker} ne $GetParam->{Invoker} ) {

        # Invoker controller mapping.
        if (
            IsHashRefWithData(
                $WebserviceData->{Config}->{Requester}->{Transport}->{Config}->{InvokerControllerMapping}
            )
            )
        {

            my $InvokerControllerMappingConfig
                = $WebserviceData->{Config}->{Requester}->{Transport}->{Config}->{InvokerControllerMapping};

            INVOKER:
            for my $Invoker ( sort keys %{$InvokerControllerMappingConfig} ) {
                next INVOKER if $Invoker ne $GetParam->{OldInvoker};

                $InvokerControllerMappingConfig->{ $GetParam->{Invoker} }
                    = delete $InvokerControllerMappingConfig->{ $GetParam->{OldInvoker} };
            }

            $WebserviceData->{Config}->{Requester}->{Transport}->{Config}->{InvokerControllerMapping}
                = $InvokerControllerMappingConfig;
        }

        # Outbound header config.
        if (
            IsHashRefWithData(
                $WebserviceData->{Config}->{Requester}->{Transport}->{Config}->{OutboundHeaders}->{Specific}
            )
            )
        {

            my $OutboundHeaderConfig
                = $WebserviceData->{Config}->{Requester}->{Transport}->{Config}->{OutboundHeaders}->{Specific};

            INVOKER:
            for my $Invoker ( sort keys %{$OutboundHeaderConfig} ) {
                next INVOKER if $Invoker ne $GetParam->{OldInvoker};

                $OutboundHeaderConfig->{ $GetParam->{Invoker} }
                    = delete $OutboundHeaderConfig->{ $GetParam->{OldInvoker} };
            }

            $WebserviceData->{Config}->{Requester}->{Transport}->{Config}->{OutboundHeaders}->{Specific}
                = $OutboundHeaderConfig;
        }

    }
# ---

    my $UpdateSuccess = $Kernel::OM->Get('Kernel::System::GenericInterface::Webservice')->WebserviceUpdate(
        %{$WebserviceData},
        UserID => $Self->{UserID},
    );
    if ( !$UpdateSuccess ) {
        return $LayoutObject->ErrorScreen(
            Message => Translatable('Could not update web service'),
        );
    }

    # If the user would like to continue editing the invoker config, just redirect to the edit screen.
    my $RedirectURL;
    if ( $GetParam->{ContinueAfterSave} eq 1 ) {
        $RedirectURL =
            'Action='
            . $Self->{Action}
            . ';Subaction=Change;WebserviceID='
            . $Param{WebserviceID}
            . ';Invoker='
            . $LayoutObject->LinkEncode( $GetParam->{Invoker} )
            . ';EventType='
            . $GetParam->{EventType}
            . ';';
    }

    # Otherwise return to overview.
    else {
        $RedirectURL =
            'Action=AdminGenericInterfaceWebservice;Subaction=Change;WebserviceID='
            . $Param{WebserviceID}
            . ';';
    }

    return $LayoutObject->Redirect(
        OP => $RedirectURL,
    );
}

sub _DeleteAction {
    my ( $Self, %Param ) = @_;

    my $GetParam = $Self->_ParamsGet(
        Definition => [
            {
                Name      => 'Invoker',
                Type      => 'String',
                Mandatory => 1,
            },
        ],
    );

    if ( $GetParam->{Error} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => $GetParam->{Error},
        );
        return $Self->_JSONResponse( Success => 0 );
    }

    if ( !IsHashRefWithData( $Param{WebserviceData}->{Config}->{Requester}->{Invoker}->{ $GetParam->{Invoker} } ) ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Could not determine config for invoker " . $GetParam->{Invoker},
        );
        return $Self->_JSONResponse( Success => 0 );
    }

    # Remove invoker from config.
    delete $Param{WebserviceData}->{Config}->{Requester}->{Invoker}->{ $GetParam->{Invoker} };
    my $Success = $Kernel::OM->Get('Kernel::System::GenericInterface::Webservice')->WebserviceUpdate(
        %{ $Param{WebserviceData} },
        UserID => $Self->{UserID},
    );

    return $Self->_JSONResponse( Success => $Success );
}

sub _AddEvent {
    my ( $Self, %Param ) = @_;

    my $GetParam = $Self->_ParamsGet(
        Definition => [
            {
                Name      => 'Invoker',
                Type      => 'String',
                Mandatory => 1,
            },
            {
                Name      => 'NewEvent',
                Type      => 'String',
                Mandatory => 1,
            },
            {
                Name    => 'Asynchronous',
                Type    => 'String',
                Default => 0,
            },
            {
                Name    => 'EventType',
                Type    => 'String',
                Default => 'Ticket',
            },
        ],
    );

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    if ( $GetParam->{Error} ) {
        return $LayoutObject->ErrorScreen(
            Message => $GetParam->{Error},
        );
    }

    my $WebserviceData = $Param{WebserviceData};
    my $InvokerConfig  = $WebserviceData->{Config}->{Requester}->{Invoker}->{ $GetParam->{Invoker} };
    if ( !IsHashRefWithData($InvokerConfig) ) {
        return $LayoutObject->ErrorScreen(
            Message => $LayoutObject->{LanguageObject}
                ->Translate( 'Could not determine config for invoker %s', $GetParam->{Invoker} ),
        );
    }

    # Add the new event to the list.
    my @Events = IsArrayRefWithData( $InvokerConfig->{Events} ) ? @{ $InvokerConfig->{Events} } : ();
    push @Events, {
        Asynchronous => $GetParam->{Asynchronous},
        Event        => $GetParam->{NewEvent},
    };

    $InvokerConfig->{Events} = \@Events;
    $WebserviceData->{Config}->{Requester}->{Invoker}->{ $GetParam->{Invoker} } = $InvokerConfig;

    my $UpdateSuccess = $Kernel::OM->Get('Kernel::System::GenericInterface::Webservice')->WebserviceUpdate(
        %{$WebserviceData},
        UserID => $Self->{UserID},
    );
    if ( !$UpdateSuccess ) {
        return $LayoutObject->ErrorScreen(
            Message => Translatable('Could not update web service'),
        );
    }

    # Stay in edit mode.
    my $RedirectURL =
        'Action='
        . $Self->{Action}
        . ';Subaction=Change;WebserviceID='
        . $Param{WebserviceID}
        . ';Invoker='
        . $LayoutObject->LinkEncode( $GetParam->{Invoker} )
        . ';EventType='
        . $GetParam->{EventType}
        . ';';

    return $LayoutObject->Redirect(
        OP => $RedirectURL,
    );
}

sub _DeleteEvent {
    my ( $Self, %Param ) = @_;

    my $GetParam = $Self->_ParamsGet(
        Definition => [
            {
                Name      => 'Invoker',
                Type      => 'String',
                Mandatory => 1,
            },
            {
                Name      => 'EventName',
                Type      => 'String',
                Mandatory => 1,
            },
        ],
    );

    if ( $GetParam->{Error} ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => $GetParam->{Error},
        );
        return $Self->_JSONResponse( Success => 0 );
    }

    my $WebserviceData = $Param{WebserviceData};
    my $InvokerConfig  = $WebserviceData->{Config}->{Requester}->{Invoker}->{ $GetParam->{Invoker} };
    if ( !IsHashRefWithData($InvokerConfig) ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Could not determine config for invoker $GetParam->{Invoker}!",
        );
        return $Self->_JSONResponse( Success => 0 );
    }

    # delete selected event from list of events.
    if ( !IsArrayRefWithData( $InvokerConfig->{Events} ) ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => "Could not find event to delete in config config for invoker $GetParam->{Invoker}!",
        );
        return $Self->_JSONResponse( Success => 0 );
    }

    @{ $InvokerConfig->{Events} } = grep { $_->{Event} ne $GetParam->{EventName} } @{ $InvokerConfig->{Events} };
    $WebserviceData->{Config}->{Requester}->{Invoker}->{ $GetParam->{Invoker} } = $InvokerConfig;

    my $UpdateSuccess = $Kernel::OM->Get('Kernel::System::GenericInterface::Webservice')->WebserviceUpdate(
        %{$WebserviceData},
        UserID => $Self->{UserID},
    );
    if ( !$UpdateSuccess ) {
        $Kernel::OM->Get('Kernel::System::Log')->Log(
            Priority => 'error',
            Message  => 'Could not update web service',
        );
        return $Self->_JSONResponse( Success => 0 );
    }

    return $Self->_JSONResponse( Success => 1 );
}

sub _ShowScreen {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my $Output = $LayoutObject->Header();
    $Output .= $LayoutObject->NavigationBar();

    $LayoutObject->AddJSData(
        Key   => 'Invoker',
        Value => $Param{Invoker},
    );

    my %TemplateData = (
        Description => $Param{InvokerConfig}->{Description},
        InvokerType => $Param{InvokerConfig}->{Type},
        Invoker     => $Param{Invoker},
        NewInvoker  => $Param{NewInvoker} // $Param{Invoker},
# ---
# OTOBOTicketInvoker
# ---
        CountLastArticle => $Param{InvokerConfig}->{CountLastArticle},
# ---
    );

    # Handle mapping.
    my $MappingModules    = $Kernel::OM->Get('Kernel::Config')->Get('GenericInterface::Mapping::Module') || {};
    my @MappingModuleList = sort keys %{$MappingModules};
    DIRECTION:
    for my $Direction (qw(MappingInbound MappingOutbound)) {
        my $OldMapping = $Param{InvokerConfig}->{$Direction}->{Type};
        my $Mapping    = $Param{$Direction};

        $TemplateData{ $Direction . 'Strg' } = $LayoutObject->BuildSelection(
            Data          => \@MappingModuleList,
            Name          => $Direction,
            SelectedValue => $Mapping,
            Sort          => 'AlphanumericValue',
            PossibleNone  => 1,
            Class         => 'Modernize RegisterChange',
        );

        # Only show configure button if we have an unchanged existing mapping type.
        next DIRECTION if !$OldMapping;
        next DIRECTION if !$Mapping;
        next DIRECTION if $Mapping ne $OldMapping;
        next DIRECTION if !$MappingModules->{$Mapping}->{ConfigDialog};

        $LayoutObject->Block(
            Name => $Direction . 'ConfigureButton',
            Data => {
                $Direction . ConfigDialog => $MappingModules->{$Mapping}->{ConfigDialog},
            },
        );
    }
# ---
# OTOBOTicketInvoker
# ---

    my $DynamicFieldTicketList = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldList(
        ObjectType => 'Ticket',
        ResultType => 'HASH',
    );
    my @DynamicFieldTicketNames = sort values %{$DynamicFieldTicketList};

    $TemplateData{RequestDynamicFieldsTicketStrg} = $LayoutObject->BuildSelection(
        Data       => \@DynamicFieldTicketNames,
        Name       => 'RequestDynamicFieldsTicket',
        SelectedID => $Param{InvokerConfig}->{RequestDynamicFieldsTicket}
            // \@DynamicFieldTicketNames,    # default is to select all fields
        PossibleNone => 0,
        Class        => 'Modernize',
        Multiple     => 1,
        Translation  => 0,
        Sort         => 'AlphanumericValue',
    );

    my $DynamicFieldArticleList = $Kernel::OM->Get('Kernel::System::DynamicField')->DynamicFieldList(
        ObjectType => 'Article',
        ResultType => 'HASH',
    );
    my @DynamicFieldArticleNames = sort values %{$DynamicFieldArticleList};

    $TemplateData{RequestDynamicFieldsArticleStrg} = $LayoutObject->BuildSelection(
        Data         => \@DynamicFieldArticleNames,
        Name         => 'RequestDynamicFieldsArticle',
        SelectedID   => $Param{InvokerConfig}->{RequestDynamicFieldsArticle},
        PossibleNone => 1,
        Class        => 'Modernize',
        Multiple     => 1,
        Translation  => 0,
        Sort         => 'AlphanumericValue',
    );

    # Prepare list of available and default-selected ticket fields.
    my $RequestFieldConfig = $Kernel::OM->Get('Kernel::Config')->Get('GenericInterface::Invoker::Config');
    my @RequestTicketFields;
    my @RequestTicketFieldsDefaultSelected;
    REQUESTTICKETFIELD:
    for my $RequestTicketField ( sort keys %{ $RequestFieldConfig->{Ticket} } ) {
        next REQUESTTICKETFIELD if !$RequestTicketField;
        push @RequestTicketFields, $RequestTicketField;

        next REQUESTTICKETFIELD if !$RequestFieldConfig->{Ticket}->{$RequestTicketField};
        push @RequestTicketFieldsDefaultSelected, $RequestTicketField;
    }

    $TemplateData{RequestTicketFieldsStrg} = $LayoutObject->BuildSelection(
        Data         => \@RequestTicketFields,
        Name         => 'RequestTicketFields',
        SelectedID   => $Param{InvokerConfig}->{RequestTicketFields} // \@RequestTicketFieldsDefaultSelected,
        PossibleNone => 0,
        Class        => 'Modernize',
        Multiple     => 1,
        Translation  => 0,
        Sort         => 'AlphanumericValue',
    );

    # Prepare list of available and default-selected article fields.
    my @RequestArticleFields;
    my @RequestArticleFieldsDefaultSelected;
    REQUESTARTICLEFIELD:
    for my $RequestArticleField ( sort keys %{ $RequestFieldConfig->{Article} } ) {
        next REQUESTARTICLEFIELD if !$RequestArticleField;
        push @RequestArticleFields, $RequestArticleField;

        next REQUESTARTICLEFIELD if !$RequestFieldConfig->{Article}->{$RequestArticleField};
        push @RequestArticleFieldsDefaultSelected, $RequestArticleField;
    }

    $TemplateData{RequestArticleFieldsStrg} = $LayoutObject->BuildSelection(
        Data         => \@RequestArticleFields,
        Name         => 'RequestArticleFields',
        SelectedID   => $Param{InvokerConfig}->{RequestArticleFields} // \@RequestArticleFieldsDefaultSelected,
        PossibleNone => 0,
        Class        => 'Modernize',
        Multiple     => 1,
        Translation  => 0,
        Sort         => 'AlphanumericValue',
    );

    $TemplateData{DynamicFieldListStrg} = $LayoutObject->BuildSelection(
        Data          => \@DynamicFieldTicketNames,
        Name          => 'DynamicFieldList',
        SelectedValue => $Param{InvokerConfig}->{DynamicFieldList},
        PossibleNone  => 1,
        Class         => 'Modernize',
        Multiple      => 1,
        Translation   => 0,
        Sort          => 'AlphanumericValue',
    );

    $TemplateData{TicketIdToDynamicFieldStrg} = $LayoutObject->BuildSelection(
        Data          => \@DynamicFieldTicketNames,
        Name          => 'TicketIdToDynamicField',
        SelectedValue => $Param{InvokerConfig}->{TicketIdToDynamicField},
        PossibleNone  => 1,
        Class         => 'Modernize ' . ( $Param{TicketIdToDynamicFieldServerError} || '' ),
        Multiple      => 0,
        Translation   => 0,
        Sort          => 'AlphanumericValue',
    );

    # Build communication channel list.
    my @CommunicationChannels = $Kernel::OM->Get('Kernel::System::CommunicationChannel')->ChannelList(
        ValidID => 1,
    );
    my @Channels = map { $_->{DisplayName} } @CommunicationChannels;
    $TemplateData{CommunicationChannelStrg} = $LayoutObject->BuildSelection(
        Data        => \@Channels,
        SelectedID  => $Param{InvokerConfig}->{CommunicationChannel},
        Translation => 1,
        Multiple    => 1,
        Sort        => 'AlphanumericValue',
        Name        => 'CommunicationChannel',
        Class       => 'Modernize',
    );

    # Build customer visibility list.
    $TemplateData{CustomerVisibilityStrg} = $LayoutObject->BuildSelection(
        Data => {
            0 => Translatable('Invisible only'),
            1 => Translatable('Visible only'),
            2 => Translatable('Visible and invisible'),
        },
        SelectedID  => $Param{InvokerConfig}->{CustomerVisibility} // 2,
        Translation => 1,
        Sort        => 'NumericKey',
        Name        => 'CustomerVisibility',
        Class       => 'Modernize',
    );

    # Build article sender type list.
    my %ArticleSenderTypeList = $Kernel::OM->Get('Kernel::System::Ticket::Article')->ArticleSenderTypeList(
        Result => 'HASH',
    );
    my @ArticleSenderTypeNames = sort values %ArticleSenderTypeList;
    $TemplateData{ArticleSenderTypeStrg} = $LayoutObject->BuildSelection(
        Data         => \@ArticleSenderTypeNames,
        SelectedID   => $Param{InvokerConfig}->{ArticleSenderType},
        Multiple     => 1,
        Sort         => 'AlphanumericValue',
        Name         => 'ArticleSenderType',
        Class        => 'Modernize',
        PossibleNone => 1,
    );
# ---

    if ( $Param{Mode} eq 'Change' ) {

        # Show all invoker event triggers.
        my $InvokerEvents = $Param{InvokerConfig}->{Events} // [];
        if ( !IsArrayRefWithData($InvokerEvents) ) {
            $LayoutObject->Block(
                Name => 'NoDataFoundMsg',
                Data => {},
            );
        }

        # Create the event triggers table.
        my @Events;
        my %InvokerEventLookup;
        my %RegisteredEvents = $Kernel::OM->Get('Kernel::System::Event')->EventList();
        for my $Event ( @{$InvokerEvents} ) {
            push @Events, $Event->{Event};

            # To store the events that are already assigned to this invoker
            #   the selects should look for this values and omit them from their lists.
            $InvokerEventLookup{ $Event->{Event} } = 1;

            # Set the event type (event object like Article or Ticket).
            # Value not currently in use but kept as it might be needed in the future.
            my $EventType;
            EVENTTYPE:
            for my $Type ( sort keys %RegisteredEvents ) {
                next EVENTTYPE if !IsArrayRefWithData( $RegisteredEvents{$Type} );
                next EVENTTYPE if !grep { $_ eq $Event->{Event} } @{ $RegisteredEvents{$Type} };

                $EventType = $Type;
                last EVENTTYPE;
            }

            $LayoutObject->Block(
                Name => 'EventRow',
                Data => {
                    WebserviceID => $Param{WebserviceID},
                    Invoker      => $Param{Invoker},
                    Event        => $Event->{Event},
                    Type         => $EventType // '-',
                    Asynchronous => $Event->{Asynchronous} ? Translatable('Yes') : Translatable('No'),
                    Condition    => IsHashRefWithData( $Event->{Condition} ) ? Translatable('Yes') : Translatable('No'),
                },
            );
        }

        $LayoutObject->AddJSData(
            Key   => 'Events',
            Value => \@Events
        );

        # Create event trigger selectors (one for each type).
        my @EventTypeList;
        TYPE:
        for my $Type ( sort keys %RegisteredEvents ) {
            next EVENTTYPE if !IsArrayRefWithData( $RegisteredEvents{$Type} );

            # Refresh event list for each event type.
            my @EventList = grep { !$InvokerEventLookup{$_} } @{ $RegisteredEvents{$Type} };

            # hide inactive event lists
            my $EventListHidden = '';
            if ( $Type ne $Param{EventType} ) {
                $EventListHidden = 'Hidden';
            }

            my $EventStrg = $LayoutObject->BuildSelection(
                Data         => \@EventList,
                Name         => $Type . 'Event',
                Sort         => 'AlphanumericValue',
                PossibleNone => 0,
                Title        => $LayoutObject->{LanguageObject}->Translate('Event'),
                Class        => 'Modernize EventList GenericInterfaceSpacing ' . $EventListHidden,
            );

            $LayoutObject->Block(
                Name => 'EventAdd',
                Data => {
                    EventStrg => $EventStrg,
                },
            );

            push @EventTypeList, $Type;
        }

        # Create event type selector.
        $TemplateData{EventTypeStrg} = $LayoutObject->BuildSelection(
            Data          => \@EventTypeList,
            Name          => 'EventType',
            Sort          => 'AlphanumericValue',
            SelectedValue => $Param{EventType},
            PossibleNone  => 0,
            Class         => 'Modernize',
        );
    }

    $Output .= $LayoutObject->Output(
        TemplateFile => $Self->{Action},
        Data         => {
            %Param,
            %TemplateData,
            WebserviceName => $Param{WebserviceData}->{Name},
        },
    );

    $Output .= $LayoutObject->Footer();
    return $Output;
}

sub _ParamsGet {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ParamObject  = $Kernel::OM->Get('Kernel::System::Web::Request');
    my %GetParam;
    DEFINITION:
    for my $Definition ( @{ $Param{Definition} } ) {
        my $Name = $Definition->{Name};

        if ( $Definition->{Type} eq 'String' ) {
            $GetParam{$Name} = $ParamObject->GetParam( Param => $Name ) // $Definition->{Default};
            next DEFINITION if IsStringWithData( $GetParam{$Name} );

            next DEFINITION if !$Definition->{Mandatory};
            $GetParam{Error} = $LayoutObject->{LanguageObject}->Translate( 'Need %s', $Name );
            return \%GetParam;
        }
# ---
# OTOBOTicketInvoker
# ---

        if ( $Definition->{Type} eq 'Array' ) {
            $GetParam{$Name} = [ $ParamObject->GetArray( Param => $Name ) ];
            next DEFINITION if IsArrayRefWithData( $GetParam{$Name} );

            next DEFINITION if !$Definition->{Mandatory};
            $GetParam{Error} = Translatable( 'Need %s', $Name );
            return \%GetParam;
        }
# ---
    }

    # Type checks.
    DEFINITION:
    for my $Definition ( @{ $Param{Definition} } ) {
        next DEFINITION if !$Definition->{Check};

        my $Name = $Definition->{Name};
        next DEFINITION if !defined $GetParam{$Name};

        if ( $Definition->{Check} eq 'InvokerType' ) {
            next DEFINITION if $Self->_InvokerTypeCheck( InvokerType => $GetParam{$Name} );

            $GetParam{Error}
                = $LayoutObject->{LanguageObject}->Translate( 'InvokerType %s is not registered', $GetParam{$Name} );
            return \%GetParam;
        }

        if ( $Definition->{Check} eq 'MappingType' ) {
            next DEFINITION if !IsStringWithData( $GetParam{Name} );
            next DEFINITION if $Self->_MappingTypeCheck( MappingType => $GetParam{$Name} );

            $GetParam{Error}
                = $LayoutObject->{LanguageObject}->Translate( 'MappingType %s is not registered', $GetParam{$Name} );
            return \%GetParam;
        }
    }

    return \%GetParam;
}

sub _InvokerTypeCheck {
    my ( $Self, %Param ) = @_;

    return if !$Param{InvokerType};

    my $Invokers = $Kernel::OM->Get('Kernel::Config')->Get('GenericInterface::Invoker::Module');
    return if !IsHashRefWithData($Invokers);

    return if !IsHashRefWithData( $Invokers->{ $Param{InvokerType} } );
    return 1;
}

sub _MappingTypeCheck {
    my ( $Self, %Param ) = @_;

    return if !$Param{MappingType};

    my $Mappings = $Kernel::OM->Get('Kernel::Config')->Get('GenericInterface::Mapping::Module');
    return if !IsHashRefWithData($Mappings);

    return if !IsHashRefWithData( $Mappings->{ $Param{MappingType} } );
    return 1;
}

sub _JSONResponse {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # Build JSON output.
    my $JSON = $LayoutObject->JSONEncode(
        Data => {
            Success => $Param{Success} // 0,
        },
    );

    # Send JSON response.
    return $LayoutObject->Attachment(
        ContentType => 'application/json; charset=' . $LayoutObject->{Charset},
        Content     => $JSON,
        Type        => 'inline',
        NoCache     => 1,
    );
}

1;