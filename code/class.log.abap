*&---------------------------------------------------------------------*
*&  Include           /YGA/LFG_MDG_CHACARATCLS
*&---------------------------------------------------------------------*
CLASS log_handle DEFINITION FINAL CREATE PUBLIC .

    PUBLIC SECTION.
  
      "! Step type for logging queue
      TYPES ty_step TYPE char02.
  
      CONSTANTS:
        "! Enumeration of logging steps
        BEGIN OF step,
          init         TYPE ty_step VALUE 'IN',
          type         TYPE ty_step VALUE 'TP',
          full_list    TYPE ty_step VALUE 'FL',
          inapplicable TYPE ty_step VALUE 'IP',
          empty_list   TYPE ty_step VALUE 'EL',
          locked_list  TYPE ty_step VALUE 'LL',
          bapi_init    TYPE ty_step VALUE 'IB',
          error_list   TYPE ty_step VALUE 'ER',
          success_list TYPE ty_step VALUE 'SU',
          done         TYPE ty_step VALUE 'DN',
        END OF step.
  
      "! Constructor - Creates message list instance
      METHODS constructor.
  
      "! @parameter result | Instance of the log queue class
      CLASS-METHODS get_instance
        RETURNING VALUE(result) TYPE REF TO log_handle.
  
      "! Delete singleton instance and perform garbage collection
      CLASS-METHODS delete_instance.
  
      "! Store log entry with associated data
      "! @parameter im_step     | Logging step
      "! @parameter im_order    | Order number
      "! @parameter im_op_elim  | Operation elimination flag
      "! @parameter im_pep_list | List of PEP elements
      "! @parameter im_msg_bapi | List of messages
      "! @parameter im_msg_list | List of messages
      METHODS store_log
        IMPORTING im_step     TYPE ty_step
                  im_order    TYPE aufnr        OPTIONAL
                  im_op_elim  TYPE sap_bool     OPTIONAL
                  im_pep_list TYPE bwps_t_posid OPTIONAL
                  im_msg_bapi TYPE bapiret2_t   OPTIONAL.
  
      "! Save accumulated log messages
      METHODS save.
  
  
    PROTECTED SECTION.
    PRIVATE SECTION.
  
      CLASS-DATA go_instance TYPE REF TO log_handle.
      DATA go_message_list TYPE REF TO if_reca_message_list.
  
      CONSTANTS:
        "! Log configuration constants
        BEGIN OF lc_log,
          object    TYPE balobj_d  VALUE '/YGA/JUMP',
          subobject TYPE balsubobj VALUE 'PEP_ENTE',
        END OF lc_log,
  
        "! Message configuration constants
        BEGIN OF lc_msg,
          id TYPE symsgid VALUE '/YGA/JUMP',
          "! Message types
          BEGIN OF type,
            info    TYPE symsgty VALUE 'I',
            error   TYPE symsgty VALUE 'E',
            success TYPE symsgty VALUE 'S',
          END OF type,
          "! Message numbers
          BEGIN OF number,
            init_process   TYPE symsgno VALUE '889',
            tech_closure   TYPE symsgno VALUE '890',
            invalid_pep    TYPE symsgno VALUE '891',
            pep_processing TYPE symsgno VALUE '892',
            process_finish TYPE symsgno VALUE '893',
            no_items       TYPE symsgno VALUE '894',
            init_bapi      TYPE symsgno VALUE '896',
          END OF number,
        END OF lc_msg.
        
      "! Get log expiration date
      "! @parameter rv_date | Expiration date
      METHODS get_expiration_date
        RETURNING VALUE(rv_date) TYPE recadatefrom.
        
  
  ENDCLASS.
  
  CLASS log_handle IMPLEMENTATION.
  
    METHOD constructor.
      me->go_message_list = cf_reca_message_list=>create( id_object    = lc_log-object
                                                      id_subobject = lc_log-subobject
                                                      id_deldate   = get_expiration_date( ) ).
    ENDMETHOD.
  
    METHOD get_instance.
      IF go_instance IS NOT BOUND.
        go_instance = NEW #( ).
      ENDIF.
      result = go_instance.
    ENDMETHOD.
  
    METHOD delete_instance.
      CLEAR go_instance.
      cl_abap_memory_utilities=>do_garbage_collection( ).
    ENDMETHOD.
  
    METHOD store_log.
    ENDMETHOD.
  
    METHOD save.
    
      me->go_message_list->store( EXPORTING  if_in_update_task = abap_true
                              EXCEPTIONS error             = 1
                                         OTHERS            = 2 ).
      IF sy-subrc <> 0.
        RETURN.
      ENDIF.
  
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.
  
    ENDMETHOD.
    
    METHOD get_expiration_date.
      /yga/cl_log=>get_expiration_dates( IMPORTING ex_aldate_del = rv_date ).
    ENDMETHOD.
    
  
  ENDCLASS.