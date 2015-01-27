function roc(obj,x,y)

% Convert y
y = obj.response2mat(y);

% Make the predictions
p = obj.predict(x);

% Vary the decision threshold from 0 to 1
X = linspace(0,1,100);
for idx = 1:length(X)
    % Get the categories and confusion matrix
    [~,Y] = max(p+X(idx),[],2);
    cm    = confusionmat(y,Y); 

    % Calculate the true positive rate
    tpr(idx) = cm(1)/sum(cm(:,1));
    fnr(idx) = cm(3)/sum(cm(:,2));
end

% Create the curve
[X,Y] = perfcurve(y,p(:,2),'NP');
g = obj.training.indVar;
B = obj.training.B;

% Process the x data
x = obj.model(x);
x = x(:,obj.covIdx);

% Determine min/max function value
z = nan(size(x,1),obj.k-1);
for idx = 1:obj.k-1
    z(:,idx) = g(idx)-B(1)-B(2:end)'*x';
end
switch obj.link
    case 'logit'

        
    case 'probit'
end

disp('HHHHHHHHHHHIIIIIIIII');