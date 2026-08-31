<%-- 
    Document   : modals
    Created on : Sep 12, 2023, 10:34:52 PM
    Author     : Imtiaz
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!-- modal content -->
<div style="display: none;" id="modal-success" class="modal hide">
    <div class="modal-header">
        <h4>Success!</h4>
    </div>
    <div class="modal-body">
        <p></p>
    </div>
    <div class="modal-footer">
        <a href="javascript://" class="btn btn-primary btnModalClose no-ajaxy">Close</a>
    </div>
</div>
<div style="display: none;" id="modal-error" class="modal hide">
    <div class="modal-header">
        <h4>Error!</h4>
    </div>
    <div class="modal-body">
        <p>Looks like you forgot to set properties for <strong>Question 1</strong></p>
    </div>
    <div class="modal-footer">
        <a href="javascript://" class="btn btn-primary btnModalClose no-ajaxy">Close</a>
    </div>
</div>
<!-- End modal content -->


<!-- modal content -->
<div style="display: none;" id="modal-confirmation" class="modal hide">
    <div class="modal-header">
        <h4>Question delete confirmation</h4>
    </div>
    <div class="modal-body">
        <p>Are you sure you want to delete the question?</p>
        <p><strong>This cannot be undone!</strong></p>
    </div>
    <div class="modal-footer">
        <a href="javascript://" class="btn btnModalClose no-ajaxy">Cancel</a>
        <a href="javascript://" class="btn btn-danger btnContinueDelete no-ajaxy">Delete</a>
    </div>
</div>

<div style="display: none;" id="modal-existing-question-confirmation" class="modal hide">
    <div class="modal-header">
        <h4>Existing question name confirmation</h4>
    </div>
    <div id="modal-existing-question-body" style="padding: 10px 20px 10px 20px;">

    </div>
    <div class="modal-footer">
        <a href="javascript://" class="btn btnModalClose no-ajaxy">Cancel</a>
        <a href="javascript://" class="btn btnModalClose no-ajaxy" onclick="saveQuestionnaire(0, 1)">Save</a>
    </div>
</div>
<!-- End modal content -->