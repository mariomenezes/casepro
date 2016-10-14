#============================================================================
# Modal dialog controllers
#============================================================================

modals = angular.module('cases.modals', []);

URN_SCHEMES = {tel: "Phone", twitter: "Twitter", mailto: "Email"}
ANYONE = {id: null, name: "-- Anyone --"}


#=====================================================================
# Simple confirmation modal
#=====================================================================
modals.controller 'ConfirmModalController', ['$scope', '$uibModalInstance', 'prompt', 'style', ($scope, $uibModalInstance, prompt, style) ->
  $scope.title = "Confirm"
  $scope.prompt = prompt
  $scope.style = style or 'primary'

  $scope.ok = () -> $uibModalInstance.close(true)
  $scope.cancel = () -> $uibModalInstance.dismiss(false)
]


#=====================================================================
# Confirm with note modal
#=====================================================================
modals.controller 'NoteModalController', ['$scope', '$uibModalInstance', 'title', 'prompt', 'style', 'maxLength', ($scope, $uibModalInstance, title, prompt, style, maxLength) ->
  $scope.title = title
  $scope.prompt = prompt
  $scope.style = style or 'primary'
  $scope.fields = {note: {val: '', maxLength: maxLength}}

  $scope.ok = () ->
    $scope.form.submitted = true

    if $scope.form.$valid
      $uibModalInstance.close($scope.fields.note.val)

  $scope.cancel = () -> $uibModalInstance.dismiss(false)
]


#=====================================================================
# Edit text modal
#=====================================================================
modals.controller 'EditModalController', ['$scope', '$uibModalInstance', 'title', 'initial', 'maxLength', ($scope, $uibModalInstance, title, initial, maxLength) ->
  $scope.title = title
  $scope.fields = {text: {val: initial, maxLength: maxLength}}

  $scope.ok = () ->
    if $scope.form.$valid
      $uibModalInstance.close($scope.fields.text.val)

  $scope.cancel = () -> $uibModalInstance.dismiss(false)
]


#=====================================================================
# Reply to contacts modal
#=====================================================================
modals.controller('ReplyModalController', ['$scope', '$uibModalInstance', 'selection', 'maxLength', ($scope, $uibModalInstance, selection, maxLength) ->
  $scope.fields = {text: {val: '', maxLength: maxLength}}
  $scope.sendToMany = if selection then true else false

  $scope.ok = () ->
    $scope.form.submitted = true
    if $scope.form.$valid
      $uibModalInstance.close($scope.fields.text.val)

  $scope.cancel = () -> $uibModalInstance.dismiss(false)
])


#=====================================================================
# Open new case modal
#=====================================================================
modals.controller 'NewCaseModalController', ['$scope', '$uibModalInstance', 'summaryInitial', 'summaryMaxLength', 'partners', 'UserService', ($scope, $uibModalInstance, summaryInitial, summaryMaxLength, partners, UserService) ->
  $scope.partners = partners
  $scope.users = [ANYONE]

  $scope.fields = {
    summary: {val: summaryInitial, maxLength: summaryMaxLength},
    assignee: {val: if partners then partners[0] else null},
    user: {val: ANYONE}
  }

  $scope.refreshUserList = () ->
    UserService.fetchInPartner($scope.fields.assignee.val, false).then((users) ->
      $scope.users = [ANYONE].concat(users)
      $scope.fields.user.val = ANYONE
    )

  $scope.ok = () ->
    $scope.form.submitted = true
    if $scope.form.$valid
      $uibModalInstance.close({
        summary: $scope.fields.summary.val,
        assignee: $scope.fields.assignee.val,
        user: if $scope.fields.user.val.id then $scope.fields.user.val else null
      })
  $scope.cancel = () -> $uibModalInstance.dismiss(false)

  $scope.refreshUserList()
]


#=====================================================================
# Assign to partner modal
#=====================================================================
modals.controller 'AssignModalController', ['$scope', '$uibModalInstance', 'title', 'prompt', 'partners', 'UserService', ($scope, $uibModalInstance, title, prompt, partners, UserService) ->
  $scope.title = title
  $scope.prompt = prompt
  $scope.partners = partners
  $scope.users = [ANYONE]

  $scope.fields = { assignee: partners[0], user: ANYONE }

  $scope.refreshUserList = () ->
    UserService.fetchInPartner($scope.fields.assignee, false).then((users) ->
      $scope.users = [ANYONE].concat(users)
      $scope.fields.user = ANYONE
    )

  $scope.ok = () -> $uibModalInstance.close({
    assignee: $scope.fields.assignee,
    user: if $scope.fields.user.id then $scope.fields.user else null
  })
  $scope.cancel = () -> $uibModalInstance.dismiss(false)

  $scope.refreshUserList()
]


#=====================================================================
# Edit item labels modal
#=====================================================================
modals.controller('LabelModalController', ['$scope', '$uibModalInstance', 'title', 'prompt', 'labels', 'initial', ($scope, $uibModalInstance, title, prompt, labels, initial) ->
  $scope.title = title
  $scope.prompt = prompt
  $scope.selection = ({label: l, selected: (l.id in (i.id for i in initial))} for l in labels)

  $scope.ok = () ->
    selectedLabels = (item.label for item in $scope.selection when item.selected)
    $uibModalInstance.close(selectedLabels)

  $scope.cancel = () -> $uibModalInstance.dismiss(false)
])


#=====================================================================
# Compose message to URN modal
#=====================================================================
modals.controller('ComposeModalController', ['$scope', '$uibModalInstance', 'title', 'initial', 'maxLength', ($scope, $uibModalInstance, title, initial, maxLength) ->
  $scope.title = title
  $scope.fields = {
    urn: {scheme: null, path: ''},
    text: {val: initial, maxLength: maxLength}
  }

  $scope.setScheme = (scheme) ->
    $scope.fields.urn.scheme = scheme
    $scope.urn_scheme_label = URN_SCHEMES[scheme]

  $scope.ok = () ->
    $scope.form.submitted = true

    if $scope.form.$valid
      urn = {scheme: $scope.fields.urn.scheme, path: $scope.fields.urn.path, urn: ($scope.fields.urn.scheme + ':' + $scope.fields.urn.path)}
      $uibModalInstance.close({text: $scope.fields.text.val, urn: urn})

  $scope.cancel = () -> $uibModalInstance.dismiss(false)

  $scope.setScheme('tel')
])


#=====================================================================
# Message history modal
#=====================================================================
modals.controller('MessageHistoryModalController', ['$scope', '$uibModalInstance', 'MessageService', 'message', ($scope, $uibModalInstance, MessageService, message) ->
  $scope.message = message
  $scope.loading = true

  MessageService.fetchHistory($scope.message).then((actions)->
    $scope.actions = actions
    $scope.loading = false
  )

  $scope.close = () -> $uibModalInstance.dismiss(false)
])


#=====================================================================
# Date range modal
#=====================================================================
modals.controller('DateRangeModalController', ['$scope', '$uibModalInstance', 'title', 'prompt', ($scope, $uibModalInstance, title, prompt) ->
  $scope.title = title
  $scope.prompt = prompt
  $scope.fields = {after: utils.addMonths(new Date(), -6), before: new Date()}

  $scope.ok = () ->
    if $scope.form.$valid
      $uibModalInstance.close({after: $scope.fields.after, before: $scope.fields.before})

  $scope.cancel = () -> $uibModalInstance.dismiss(false)
])
